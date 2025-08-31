import SwiftUI
import HotKey

struct KeyCaptureView: View {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt
    
    @State private var isRecording: Bool = false
    
    private var hotkeyText: String {
        guard let key = Key(carbonKeyCode: keyCode) else { return "None" }
        let modifierFlags = NSEvent.ModifierFlags(rawValue: modifiers)
        return modifierFlags.description + key.description
    }
    
    var body: some View {
        HStack {
            Text(hotkeyText)
                .padding(8)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
                .frame(minWidth: 100)
            
            Button(isRecording ? "Recording..." : "Set Hotkey") {
                isRecording.toggle()
            }
        }
        .background(
            // This is a hack to capture key events in SwiftUI
            KeyCaptureRepresentable(isRecording: $isRecording, keyCode: $keyCode, modifiers: $modifiers)
                .frame(width: 0, height: 0)
        )
    }
}

private struct KeyCaptureRepresentable: NSViewRepresentable {
    @Binding var isRecording: Bool
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if self.isRecording {
                self.keyCode = UInt32(event.keyCode)
                self.modifiers = event.modifierFlags.rawValue
                self.isRecording = false
                return nil // Consume the event
            }
            return event
        }
        
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Helper for prettier modifier description
extension NSEvent.ModifierFlags {
    var description: String {
        var out = ""
        if contains(.control) { out += "⌃" }
        if contains(.option) { out += "⌥" }
        if contains(.shift) { out += "⇧" }
        if contains(.command) { out += "⌘" }
        return out
    }
}
