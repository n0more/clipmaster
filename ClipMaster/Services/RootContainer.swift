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
            self.promptService = PromptService()
            self.settingsService = SettingsService()
            self.accessibilityService = AccessibilityService()
            self.persistenceService = try PersistenceService(settingsService: self.settingsService)
            
            self.clipboardService = ClipboardService(persistenceService: self.persistenceService)
            self.hotKeyService = HotKeyService(settingsService: self.settingsService)
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
