import Foundation
import Combine

// A service to manage user settings, like the Ollama temperature.
// It saves settings to UserDefaults to persist them.
@MainActor
class SettingsService: ObservableObject {
    
    @Published var temperature: Double
    @Published var availableModels: [String] = []
    @Published var selectedModel: String
    
    private let temperatureKey = "ollamaTemperature"
    private let selectedModelKey = "ollamaSelectedModel"
    
    init() {
        let savedTemperature = UserDefaults.standard.double(forKey: temperatureKey)
        self.temperature = (savedTemperature == 0.0) ? 0.7 : savedTemperature
        
        self.selectedModel = UserDefaults.standard.string(forKey: selectedModelKey) ?? ""
    }
    
    func setTemperature(_ newTemperature: Double) {
        // Clamp the value to a reasonable range.
        let clampedTemp = max(0.0, min(2.0, newTemperature))
        self.temperature = clampedTemp
        UserDefaults.standard.set(clampedTemp, forKey: temperatureKey)
        print("[SettingsService] Temperature set to: \(clampedTemp)")
    }
    
    func setSelectedModel(_ newModel: String) {
        self.selectedModel = newModel
        UserDefaults.standard.set(newModel, forKey: selectedModelKey)
        print("[SettingsService] Model set to: \(newModel)")
    }
    
    func updateAvailableModels(_ newModels: [String]) {
        self.availableModels = newModels
        // If the currently selected model is not in the new list,
        // or if no model is selected, default to the first available one.
        if !newModels.contains(selectedModel) || selectedModel.isEmpty {
            setSelectedModel(newModels.first ?? "")
        }
    }
}
