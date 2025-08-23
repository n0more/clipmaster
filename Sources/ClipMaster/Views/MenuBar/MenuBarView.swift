import SwiftUI
import SwiftData

struct MenuBarView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
    @FocusState private var isListFocused: Bool
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Clipboard History")
                .font(.headline)
                .padding([.leading, .top, .trailing])

            if viewModel.clipItems.isEmpty {
                Text("History is empty.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ForEach(Array(viewModel.clipItems.enumerated()), id: \.element.id) { index, item in
                            // Pass the ViewModel to the row
                            ClipItemRow(item: item, viewModel: viewModel)
                                .background(selectedIndex == index ? Color.accentColor : Color.clear)
                                .cornerRadius(4)
                                .id(item.id)
                        }
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
        .onAppear {
            viewModel.fetchHistory()
            isListFocused = true
        }
        .frame(width: 300, height: 400)
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
        default:
            return
        }
        
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