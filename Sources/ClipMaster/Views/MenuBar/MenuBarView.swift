import SwiftUI
import SwiftData

struct MenuBarView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
    @FocusState private var isListFocused: Bool
    
    // We now track the index of the selected item. Default to 0 (the first item).
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
                // We use a ScrollView to have full control over the content.
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ForEach(Array(viewModel.clipItems.enumerated()), id: \.element.id) { index, item in
                            ClipItemRow(item: item)
                                .background(selectedIndex == index ? Color.accentColor : Color.clear)
                                .cornerRadius(4)
                                .id(item.id) // ID for scrolling
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
        
        // Scroll to the newly selected item.
        let selectedId = items[selectedIndex].id
        withAnimation {
            proxy.scrollTo(selectedId, anchor: .center)
        }
    }
}

// A new view for a single row to better manage its appearance.
struct ClipItemRow: View {
    let item: ClipItem
    
    var body: some View {
        HStack {
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
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
}
