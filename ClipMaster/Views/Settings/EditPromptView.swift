import SwiftUI

struct EditPromptView: View {
    @State private var promptText: String
    private let originalPrompt: String
    
    // Closures to communicate back.
    var onSave: (String, String) -> Void
    var onCancel: () -> Void
    
    init(prompt: String, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        _promptText = State(initialValue: prompt)
        self.originalPrompt = prompt
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Prompt")
                .font(.headline)
            
            Text("Use \(PromptService.clipboardPlaceholder) to insert clipboard text.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // The text field for editing the prompt.
            TextField("e.g., Explain this code: \(PromptService.clipboardPlaceholder)", text: $promptText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save", action: { onSave(originalPrompt, promptText) })
                    .keyboardShortcut(.defaultAction)
                    .disabled(promptText.isEmpty || !promptText.contains(PromptService.clipboardPlaceholder))
            }
        }
        .padding()
        .frame(width: 350)
    }
}

struct EditPromptView_Previews: PreviewProvider {
    static var previews: some View {
        EditPromptView(
            prompt: "Initial prompt text",
            onSave: { oldPrompt, newPrompt in
                print("Saved prompt: \(newPrompt) (was: \(oldPrompt))")
            },
            onCancel: {
                print("Cancelled editing prompt.")
            }
        )
    }
}
