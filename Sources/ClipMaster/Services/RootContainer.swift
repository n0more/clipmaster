import Foundation
import SwiftUI

// This container class manages the creation and lifecycle of all services and shared state.
// It's an ObservableObject, so SwiftUI can manage its lifecycle when used with @StateObject.
@MainActor
class RootContainer {
    // All services and view models are initialized here.
    let persistenceService: PersistenceService
    let clipboardService: ClipboardService
    let hotKeyService: HotKeyService
    let ollamaService: OllamaService // New service
    let historyViewModel: HistoryViewModel

    init() {
        do {
            // 1. Foundational services.
            self.persistenceService = try PersistenceService()
            
            // 2. Core services.
            self.clipboardService = ClipboardService(persistenceService: self.persistenceService)
            self.hotKeyService = HotKeyService()
            self.ollamaService = OllamaService() // New service
            
            // 3. View models that depend on services.
            self.historyViewModel = HistoryViewModel(
                modelContext: self.persistenceService.mainContext,
                clipboardService: self.clipboardService,
                ollamaService: self.ollamaService // Pass it to the ViewModel
            )
            
        } catch {
            fatalError("Failed to initialize RootContainer: \(error)")
        }
    }
    
    // Starts services that need to run in the background.
    public func startServices() {
        clipboardService.startMonitoring()
    }
}
