import SwiftUI

@main
struct ClipMasterApp: App {
    // The AppDelegate now manages the entire application lifecycle.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Provide a Settings scene. This is the modern way for menu-bar-only
        // apps to handle their lifecycle correctly without showing a main window.
        Settings {
            // An empty settings view is fine for now.
        }
    }
}

