import SwiftUI

struct OllamaURLView: View {
    @ObservedObject var settingsService: SettingsService
    var onDone: () -> Void
    
    @State private var urlText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set Ollama API URL")
                .font(.title2)
            
            Text("Enter the base URL for your Ollama instance.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("e.g., http://localhost:11434", text: $urlText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Spacer()
                Button("Done") {
                    settingsService.setOllamaURL(urlText)
                    onDone()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            self.urlText = settingsService.ollamaURL
        }
    }
}

struct OllamaURLView_Previews: PreviewProvider {
    static var previews: some View {
        OllamaURLView(settingsService: SettingsService(), onDone: {})
    }
}
