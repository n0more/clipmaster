import AppKit
import Foundation

// Service for managing accessibility permissions.
// macOS requires explicit user permission for apps to listen to global keyboard events.
class AccessibilityService {
    
    // Check if the application has accessibility permissions.
    static func hasPermissions() -> Bool {
        // This is the modern way to check for accessibility permissions.
        // It doesn't require a prompt, it just returns the current status.
        AXIsProcessTrusted()
    }
    
    // Request accessibility permissions from the user.
    // This will open the System Settings to the correct pane.
    static func requestPermissions() {
        // This is a user-facing string, but we'll keep it simple for now.
        let prompt = "Please grant accessibility permissions to enable global hotkeys."
        
        // This function call opens the System Settings pane for the user.
        // The `kAXTrustedCheckOptionPrompt.takeUnretainedValue()` part is a bit of boilerplate
        // to create the correct dictionary key for the prompt.
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt]
        
        // The function returns true if permissions are already granted,
        // but its main purpose here is to trigger the system prompt if they are not.
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
