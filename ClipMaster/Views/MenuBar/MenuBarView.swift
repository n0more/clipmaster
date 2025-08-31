import SwiftUI
import SwiftData

struct MenuBarView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
    @FocusState private var isListFocused: Bool
    @State private var selectedIndex: Int = 0

    // Constants for dynamic height calculation
    private let rowHeight: CGFloat = 50
    private let padding: CGFloat = 8
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = 500
    
    private var calculatedHeight: CGFloat {
        let itemCount = viewModel.clipItems.count
        if itemCount == 0 {
            return minHeight
        }
        let totalHeight = (CGFloat(itemCount) * rowHeight) + (padding * 2)
        return min(max(totalHeight, minHeight), maxHeight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.clipItems.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("History is empty.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        // Add some padding at the top of the scroll view
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.clipItems.enumerated()), id: \.element.id) { index, item in
                                ClipItemRow(item: item, viewModel: viewModel)
                                    .frame(height: rowHeight)
                                    .background(selectedIndex == index ? Color.accentColor.opacity(0.3) : Color.clear)
                                    .cornerRadius(4)
                                    .id(item.id)
                            }
                        }
                        .padding(.horizontal, padding)
                        .padding(.vertical, padding)
                    }
                    .focusable()
                    .focused($isListFocused)
                    .onKeyPress { press in
                        handleKeyPress(press, proxy: scrollViewProxy)
                        return .handled
                    }
                }
            }
        }
        .background(Material.regular) // Make the background opaque and light/dark adaptive
        .cornerRadius(8) // Add rounded corners to the window
        .onAppear {
            viewModel.fetchHistory()
            isListFocused = true
        }
        .frame(width: 300, height: calculatedHeight) // Use the dynamic height
    }
    
    private func handleKeyPress(_ press: KeyPress, proxy: ScrollViewProxy) {
        let items = viewModel.clipItems
        guard !items.isEmpty else { return }
        
        switch press.key {
        case .downArrow:
            selectedIndex = (selectedIndex + 1) % items.count
        case .upArrow:
            selectedIndex = (selectedIndex - 1 + items.count) % items.count
        case .return:
            let itemToCopy = items[selectedIndex]
            viewModel.copyToPasteboard(item: itemToCopy)
            NSApp.keyWindow?.close()
            return
        case .rightArrow: // New case for Ollama processing
            let itemToProcess = items[selectedIndex]
            // Ensure it's not an image before processing
            guard itemToProcess.contentType != "public.png" else { return }
            
            Task {
                await viewModel.processWithOllama(item: itemToProcess)
                // Close the window after processing is done.
                NSApp.keyWindow?.close()
            }
            return
        default:
            return
        }
        
        // Scroll to the newly selected item.
        let selectedId = items[selectedIndex].id
        withAnimation {
            proxy.scrollTo(selectedId, anchor: .center)
        }
    }
}

// Updated ClipItemRow to include the Ollama button
struct ClipItemRow: View {
    let item: ClipItem
    @ObservedObject var viewModel: HistoryViewModel // Observe the ViewModel
    
    var body: some View {
        HStack {
            // Item content
            if item.contentType == "public.png", let image = NSImage(data: item.content) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else if let text = String(data: item.content, encoding: .utf8) {
                Text(text)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Ollama processing button
            if item.contentType != "public.png" { // Only show for text items
                if viewModel.isProcessingOllama {
                    ProgressView()
                        .scaleEffect(0.5)
                } else {
                    Button(action: {
                        // Run the async task
                        Task {
                            await viewModel.processWithOllama(item: item)
                        }
                    }) {
                        Image(systemName: "brain.head.profile")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
}