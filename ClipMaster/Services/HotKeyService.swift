import AppKit
import Foundation
import HotKey
import Combine

// Define a custom notification name for toggling the history window.
extension Notification.Name {
    static let toggleHistoryWindow = Notification.Name("toggleHistoryWindow")
    static let processLastItemWithOllama = Notification.Name("processLastItemWithOllama")
    static let selectPrompt1 = Notification.Name("selectPrompt1")
    static let selectPrompt2 = Notification.Name("selectPrompt2")
    static let selectPrompt3 = Notification.Name("selectPrompt3")
}

// Service for managing the global hotkeys dynamically
@MainActor
class HotKeyService {
    
    private var historyHotKey: HotKey?
    private var processHotKey: HotKey?
    
    // Hotkeys for selecting prompts
    private var prompt1HotKey: HotKey?
    private var prompt2HotKey: HotKey?
    private var prompt3HotKey: HotKey?
    
    private let settingsService: SettingsService
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsService: SettingsService) {
        self.settingsService = settingsService
        
        // Initial setup for configurable hotkeys
        updateHistoryHotKey()
        updateProcessHotKey()
        
        // Setup for static prompt hotkeys
        setupPromptHotkeys()
        
        // Listen for future changes on configurable hotkeys
        listenForHotKeyChanges()
    }
    
    private func listenForHotKeyChanges() {
        settingsService.$historyHotKeyKeyCode
            .combineLatest(settingsService.$historyHotKeyModifiers)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // Avoid rapid updates
            .sink { [weak self] _, _ in
                self?.updateHistoryHotKey()
            }
            .store(in: &cancellables)
            
        settingsService.$processHotKeyKeyCode
            .combineLatest(settingsService.$processHotKeyModifiers)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.updateProcessHotKey()
            }
            .store(in: &cancellables)
    }
    
    private func updateHistoryHotKey() {
        historyHotKey = nil // Unregister the old one
        
        guard let key = Key(carbonKeyCode: settingsService.historyHotKeyKeyCode) else { return }
        let modifiers = NSEvent.ModifierFlags(rawValue: settingsService.historyHotKeyModifiers)
        
        historyHotKey = HotKey(key: key, modifiers: modifiers)
        historyHotKey?.keyDownHandler = {
            print("History Hotkey pressed!")
            NotificationCenter.default.post(name: .toggleHistoryWindow, object: nil)
        }
        print("History hotkey updated to: \(key) with \(modifiers)")
    }
    
    private func updateProcessHotKey() {
        processHotKey = nil // Unregister the old one
        
        guard let key = Key(carbonKeyCode: settingsService.processHotKeyKeyCode) else { return }
        let modifiers = NSEvent.ModifierFlags(rawValue: settingsService.processHotKeyModifiers)
        
        processHotKey = HotKey(key: key, modifiers: modifiers)
        processHotKey?.keyDownHandler = {
            print("Process Hotkey pressed!")
            NotificationCenter.default.post(name: .processLastItemWithOllama, object: nil)
        }
        print("Process hotkey updated to: \(key) with \(modifiers)")
    }
    
    private func setupPromptHotkeys() {
        let modifiers: NSEvent.ModifierFlags = [.control, .shift]
        
        prompt1HotKey = HotKey(key: .one, modifiers: modifiers)
        prompt1HotKey?.keyDownHandler = {
            print("Select Prompt 1 Hotkey pressed!")
            NotificationCenter.default.post(name: .selectPrompt1, object: nil)
        }
        
        prompt2HotKey = HotKey(key: .two, modifiers: modifiers)
        prompt2HotKey?.keyDownHandler = {
            print("Select Prompt 2 Hotkey pressed!")
            NotificationCenter.default.post(name: .selectPrompt2, object: nil)
        }
        
        prompt3HotKey = HotKey(key: .three, modifiers: modifiers)
        prompt3HotKey?.keyDownHandler = {
            print("Select Prompt 3 Hotkey pressed!")
            NotificationCenter.default.post(name: .selectPrompt3, object: nil)
        }
    }
}