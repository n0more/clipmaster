import AppKit

// A custom NSPanel subclass that can become the key window even if it's borderless.
// This is essential for creating interactive pop-up panels that can receive keyboard events.
class PopupPanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
}
