import AppKit
import Foundation
import HotKey

// Define a custom notification name for toggling the history window.
extension Notification.Name {
    static let toggleHistoryWindow = Notification.Name("toggleHistoryWindow")
}

// Service for managing the global hotkey
class HotKeyService {
    
    private var hotKey: HotKey?
    
    // The default hotkey is Ctrl+Shift+K
    private var key: Key = .k
    private var modifiers: NSEvent.ModifierFlags = [.control, .shift]
    
    init() {
        setupHotKey()
    }
    
    private func setupHotKey() {
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = {
            // LOG: Confirm the hotkey is working.
            print("Hotkey (Ctrl+Shift+K) pressed!")
            
            // ACTION: Post a notification that the rest of the app can listen for.
            NotificationCenter.default.post(name: .toggleHistoryWindow, object: nil)
        }
    }
}