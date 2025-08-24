import SwiftUI

struct PromptItem: Identifiable {
    let id: String
}

struct PromptsSettingsView: View {
    @ObservedObject var promptService: PromptService
    var onDone: () -> Void
    
    // State to control the presentation of the sheets.
    @State private var isAddingPrompt = false
    @State private var editingPrompt: PromptItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Prompts")
                .font(.title2)
            
            List {
                ForEach(promptService.prompts, id: \.self) { prompt in
                    HStack {
                        Text(prompt)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        Button(action: {
                            editingPrompt = PromptItem(id: prompt)
                        }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button(action: {
                            promptService.deletePrompt(prompt)
                        }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(.red)
                    }
                }
            }
            
            HStack {
                Button("Add New Prompt") {
                    isAddingPrompt = true
                }
                Spacer()
                Button("Done") {
                    onDone()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 450, height: 300)
        .sheet(isPresented: $isAddingPrompt) {
            AddPromptView(
                onSave: { newPrompt in
                    promptService.addPrompt(newPrompt)
                    isAddingPrompt = false
                },
                onCancel: {
                    isAddingPrompt = false
                }
            )
        }
        .sheet(item: $editingPrompt) { prompt in
            EditPromptView(
                prompt: prompt.id,
                onSave: { oldPrompt, newPrompt in
                    promptService.updatePrompt(old: oldPrompt, new: newPrompt)
                    editingPrompt = nil
                },
                onCancel: {
                    editingPrompt = nil
                }
            )
        }
    }
}

struct PromptsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PromptsSettingsView(promptService: PromptService(), onDone: {})
    }
}
