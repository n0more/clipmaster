import SwiftUI
import SwiftData
import Sparkle

@main
struct ClipMasterApp: App {
    // Controller for Sparkle updates. Initialized once.
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    
    // The single source of truth for all services and state.
    // SwiftUI will create and manage the lifecycle of this object.
    @StateObject private var container = RootContainer()

    var body: some Scene {
        // The `isInserted` binding now correctly controls the menu's visibility.
        // We access appState directly from the container.
        MenuBarExtra("ClipMaster", systemImage: "paperclip", isInserted: $container.appState.isMenuPresented) {
            MenuBarView(updaterController: updaterController)
                // Pass the entire container into the environment.
                .environmentObject(container)
                // Pass the necessary values required by subviews.
                .environmentObject(container.historyViewModel)
                .environmentObject(container.appState)
                .modelContainer(container.persistenceService.mainContext.container)
                .onAppear {
                    // Start services when the view appears for the first time.
                    container.startServices()
                }
        }
    }
}
