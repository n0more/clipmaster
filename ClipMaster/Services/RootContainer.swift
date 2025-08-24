import Foundation
import SwiftUI

// This container class manages the creation and lifecycle of all services and shared state.
// It's an ObservableObject, so SwiftUI can manage its lifecycle when used with @StateObject.
@MainActor
class RootContainer {
    let persistenceService: PersistenceService
    let clipboardService: ClipboardService
    let hotKeyService: HotKeyService
    let ollamaService: OllamaService
    let promptService: PromptService
    let settingsService: SettingsService
    let accessibilityService: AccessibilityService
    let historyViewModel: HistoryViewModel

    init() {
        do {
            self.persistenceService = try PersistenceService()
            self.promptService = PromptService()
            self.settingsService = SettingsService()
            self.accessibilityService = AccessibilityService()
            
            self.clipboardService = ClipboardService(persistenceService: self.persistenceService)
            self.hotKeyService = HotKeyService()
            self.ollamaService = OllamaService()
            
            self.historyViewModel = HistoryViewModel(
                modelContext: self.persistenceService.mainContext,
                clipboardService: self.clipboardService,
                ollamaService: self.ollamaService,
                promptService: self.promptService,
                settingsService: self.settingsService // Pass it to the ViewModel
            )
            
        } catch {
            fatalError("Failed to initialize RootContainer: \(error)")
        }
    }
    
    public func startServices() {
        clipboardService.startMonitoring()
    }
}
