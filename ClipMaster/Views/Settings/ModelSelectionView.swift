import SwiftUI

struct ModelSelectionView: View {
    @ObservedObject var settingsService: SettingsService
    var onDone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Ollama Model")
                .font(.title2)
            
            if settingsService.availableModels.isEmpty {
                Text("No models found. Make sure Ollama is running.")
                    .foregroundColor(.secondary)
            } else {
                Picker("Model:", selection: $settingsService.selectedModel) {
                    ForEach(settingsService.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            HStack {
                Spacer()
                Button("Done", action: onDone)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            // This is a placeholder. The actual fetch should be triggered
            // from a higher-level controller that owns OllamaService.
        }
    }
}

struct ModelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = SettingsService()
        settings.availableModels = ["llama2:latest", "codellama:latest"]
        settings.selectedModel = "llama2:latest"
        
        return ModelSelectionView(settingsService: settings, onDone: {})
    }
}
