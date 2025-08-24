import SwiftUI

struct AddPromptView: View {
    @State private var promptText: String = ""
    
    // Closures to communicate back to the AppController.
    var onSave: (String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add New Prompt")
                .font(.headline)
            
            Text("Use \(PromptService.clipboardPlaceholder) to insert clipboard text.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // The text field for the new prompt.
            TextField("e.g., Explain this code: \(PromptService.clipboardPlaceholder)", text: $promptText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction) // Allows pressing Esc
                
                Spacer()
                
                Button("Save", action: { onSave(promptText) })
                    .keyboardShortcut(.defaultAction) // Allows pressing Enter
                    .disabled(promptText.isEmpty || !promptText.contains(PromptService.clipboardPlaceholder))
            }
        }
        .padding()
        .frame(width: 350)
    }
}
