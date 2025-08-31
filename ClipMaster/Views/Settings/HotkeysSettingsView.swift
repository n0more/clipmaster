import SwiftUI

struct HotkeysSettingsView: View {
    @ObservedObject var settingsService: SettingsService
    var onDone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configure Hotkeys")
                .font(.title2)
            
            Form {
                HStack {
                    Text("Show History:")
                    Spacer()
                    KeyCaptureView(
                        keyCode: $settingsService.historyHotKeyKeyCode,
                        modifiers: $settingsService.historyHotKeyModifiers
                    )
                }
                
                HStack {
                    Text("Process Last Item:")
                    Spacer()
                    KeyCaptureView(
                        keyCode: $settingsService.processHotKeyKeyCode,
                        modifiers: $settingsService.processHotKeyModifiers
                    )
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done", action: onDone)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 450, height: 200)
    }
}

struct HotkeysSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeysSettingsView(settingsService: SettingsService(), onDone: {})
    }
}
