import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // The single source of truth for all services and state.
    private var rootContainer: RootContainer!
    
    // This controller will live for the entire duration of the app's lifecycle.
    private var appController: AppController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 1. Create the container with all the app's data and services.
        self.rootContainer = RootContainer()
        
        // 2. Create the controller, passing it the data it needs.
        self.appController = AppController(container: rootContainer)
        
        // 3. Start background services like clipboard monitoring.
        self.rootContainer.startServices()
        
        // 4. Now that the app is fully launched, check for permissions.
        #if !DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.appController.checkAccessibilityPermissions()
        }
        #endif
    }
}