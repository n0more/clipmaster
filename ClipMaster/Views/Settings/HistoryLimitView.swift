import SwiftUI

struct HistoryLimitView: View {
    @ObservedObject var settingsService: SettingsService
    var onDone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set History Limit")
                .font(.title2)
            
            Text("Set the maximum number of items to keep in your clipboard history.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Stepper(value: $settingsService.historyLimit, in: 1...100) {
                Text("History items: \(settingsService.historyLimit)")
            }
            
            HStack {
                Spacer()
                Button("Done") {
                    // The value is already updated via the binding,
                    // so we just need to call onDone.
                    // The service will handle saving.
                    settingsService.setHistoryLimit(settingsService.historyLimit)
                    onDone()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

struct HistoryLimitView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryLimitView(settingsService: SettingsService(), onDone: {})
    }
}
