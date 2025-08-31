import Foundation
import Combine
import AppKit

// A service to manage user settings, like the Ollama temperature.
// It saves settings to UserDefaults to persist them.
@MainActor
class SettingsService: ObservableObject {
    
    @Published var temperature: Double
    @Published var availableModels: [String] = []
    @Published var selectedModel: String
    @Published var ollamaURL: String
    
    // Hotkey settings
    @Published var historyHotKeyKeyCode: UInt32
    @Published var historyHotKeyModifiers: UInt
    @Published var processHotKeyKeyCode: UInt32
    @Published var processHotKeyModifiers: UInt
    
    private let temperatureKey = "ollamaTemperature"
    private let selectedModelKey = "ollamaSelectedModel"
    private let ollamaURLKey = "ollamaURL"
    
    // UserDefaults keys for hotkeys
    private let historyHotKeyKeyCodeKey = "historyHotKeyKeyCode"
    private let historyHotKeyModifiersKey = "historyHotKeyModifiers"
    private let processHotKeyKeyCodeKey = "processHotKeyKeyCode"
    private let processHotKeyModifiersKey = "processHotKeyModifiers"
    
    init() {
        let savedTemperature = UserDefaults.standard.double(forKey: temperatureKey)
        self.temperature = (savedTemperature == 0.0) ? 0.7 : savedTemperature
        
        self.selectedModel = UserDefaults.standard.string(forKey: selectedModelKey) ?? ""
        self.ollamaURL = UserDefaults.standard.string(forKey: ollamaURLKey) ?? "http://localhost:11434"
        
        // Load hotkey settings or set defaults
        // Default: Ctrl+Shift+K (keyCode 40)
        self.historyHotKeyKeyCode = UInt32(UserDefaults.standard.integer(forKey: historyHotKeyKeyCodeKey, defaultValue: 40))
        self.historyHotKeyModifiers = UInt(UserDefaults.standard.integer(forKey: historyHotKeyModifiersKey, defaultValue: Int(NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.shift.rawValue)))
        
        // Default: Ctrl+Shift+R (keyCode 15)
        self.processHotKeyKeyCode = UInt32(UserDefaults.standard.integer(forKey: processHotKeyKeyCodeKey, defaultValue: 15))
        self.processHotKeyModifiers = UInt(UserDefaults.standard.integer(forKey: processHotKeyModifiersKey, defaultValue: Int(NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.shift.rawValue)))
    }
    
    func setHistoryHotKey(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) {
        self.historyHotKeyKeyCode = keyCode
        self.historyHotKeyModifiers = modifiers.rawValue
        UserDefaults.standard.set(Int(keyCode), forKey: historyHotKeyKeyCodeKey)
        UserDefaults.standard.set(Int(modifiers.rawValue), forKey: historyHotKeyModifiersKey)
    }
    
    func setProcessHotKey(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) {
        self.processHotKeyKeyCode = keyCode
        self.processHotKeyModifiers = modifiers.rawValue
        UserDefaults.standard.set(Int(keyCode), forKey: processHotKeyKeyCodeKey)
        UserDefaults.standard.set(Int(modifiers.rawValue), forKey: processHotKeyModifiersKey)
    }
    
    func setTemperature(_ newTemperature: Double) {
        let clampedTemp = max(0.0, min(2.0, newTemperature))
        self.temperature = clampedTemp
        UserDefaults.standard.set(clampedTemp, forKey: temperatureKey)
        print("[SettingsService] Temperature set to: \(clampedTemp)")
    }
    
    func setOllamaURL(_ newURL: String) {
        self.ollamaURL = newURL
        UserDefaults.standard.set(newURL, forKey: ollamaURLKey)
        print("[SettingsService] Ollama URL set to: \(newURL)")
    }
    
    func setSelectedModel(_ newModel: String) {
        self.selectedModel = newModel
        UserDefaults.standard.set(newModel, forKey: selectedModelKey)
        print("[SettingsService] Model set to: \(newModel)")
    }
    
    func updateAvailableModels(_ newModels: [String]) {
        self.availableModels = newModels
        if !newModels.contains(selectedModel) || selectedModel.isEmpty {
            setSelectedModel(newModels.first ?? "")
        }
    }
}

// Helper to handle default values in UserDefaults
extension UserDefaults {
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if self.object(forKey: key) == nil {
            return defaultValue
        }
        return self.integer(forKey: key)
    }
}
