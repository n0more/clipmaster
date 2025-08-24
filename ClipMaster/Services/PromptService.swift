import Foundation
import Combine

// A service to manage user-defined prompts.
@MainActor
class PromptService: ObservableObject {
    
    @Published var prompts: [String]
    @Published var activePrompt: String
    
    private let promptsKey = "userPrompts"
    private let activePromptKey = "activePrompt"
    
    static let clipboardPlaceholder = "{{clipboard}}"

    init() {
        let savedPrompts = UserDefaults.standard.stringArray(forKey: promptsKey)
        let savedActivePrompt = UserDefaults.standard.string(forKey: activePromptKey)
        
        let defaultPrompts = [
            "Summarize this text: \(PromptService.clipboardPlaceholder)",
            "Translate to English: \(PromptService.clipboardPlaceholder)",
            "Fix grammar and spelling: \(PromptService.clipboardPlaceholder)"
        ]
        
        // 1. Determine the final prompts array first and store it in a local variable.
        let finalPrompts = savedPrompts ?? defaultPrompts
        
        // 2. Now, determine the active prompt based on the local `finalPrompts` variable.
        var finalActivePrompt = savedActivePrompt ?? finalPrompts.first ?? ""
        
        // 3. Ensure consistency. If the saved active prompt isn't in the list, default to the first.
        if !finalPrompts.contains(finalActivePrompt) {
            finalActivePrompt = finalPrompts.first ?? ""
        }
        
        // 4. Now that all values are determined, assign them to the class properties.
        self.prompts = finalPrompts
        self.activePrompt = finalActivePrompt
    }
    
    func addPrompt(_ prompt: String) {
        guard prompt.contains(PromptService.clipboardPlaceholder) else {
            print("Error: Prompt must include the \(PromptService.clipboardPlaceholder) placeholder.")
            return
        }
        prompts.append(prompt)
        savePrompts()
    }
    
    func setActivePrompt(_ prompt: String) {
        guard prompts.contains(prompt) else { return }
        activePrompt = prompt
        UserDefaults.standard.set(activePrompt, forKey: activePromptKey)
        print("[PromptService] Active prompt set to: \(activePrompt)")
    }

    func updatePrompt(old: String, new: String) {
        guard new.contains(PromptService.clipboardPlaceholder) else {
            print("Error: Prompt must include the \(PromptService.clipboardPlaceholder) placeholder.")
            return
        }
        if let index = prompts.firstIndex(of: old) {
            prompts[index] = new
            if activePrompt == old {
                setActivePrompt(new)
            }
            savePrompts()
        }
    }

    func deletePrompt(_ prompt: String) {
        prompts.removeAll { $0 == prompt }
        if activePrompt == prompt {
            activePrompt = prompts.first ?? ""
            UserDefaults.standard.set(activePrompt, forKey: activePromptKey)
        }
        savePrompts()
    }
    
    private func savePrompts() {
        UserDefaults.standard.set(prompts, forKey: promptsKey)
    }
}