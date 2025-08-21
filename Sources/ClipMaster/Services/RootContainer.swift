import Foundation
import SwiftUI

// This container class manages the creation and lifecycle of all services and shared state.
// It's an ObservableObject, so SwiftUI can manage its lifecycle when used with @StateObject.
@MainActor
class RootContainer: ObservableObject {
    // Shared State - now published so views can react to changes if needed
    @Published var appState: AppState
    
    // Services
    let persistenceService: PersistenceService
    let clipboardService: ClipboardService
    let hotKeyService: HotKeyService
    
    // ViewModels - also published
    @Published var historyViewModel: HistoryViewModel

    init() {
        do {
            // 1. Create shared state first.
            let appState = AppState()
            self.appState = appState
            
            // 2. Create persistence layer.
            self.persistenceService = try PersistenceService()
            
            // 3. Create services.
            self.clipboardService = ClipboardService(persistenceService: self.persistenceService)
            self.hotKeyService = HotKeyService()
            
            // 4. Create view models that depend on services.
            self.historyViewModel = HistoryViewModel(modelContext: self.persistenceService.mainContext, clipboardService: self.clipboardService)
            
        } catch {
            // If any part of the initialization fails, the app cannot run.
            fatalError("Failed to initialize the application's container: \(error)")
        }
    }
    
    // Starts services that need to run in the background.
    public func startServices() {
        clipboardService.startMonitoring()
    }
}
