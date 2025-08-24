import SwiftUI

struct AccessibilityAlertView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Permission Required")
                .font(.largeTitle)
            
            Text("ClipMaster needs Accessibility permissions to use global hotkeys. This allows the app to respond to your shortcuts even when it's in the background.")
                .multilineTextAlignment(.center)
            
            Button("Open System Settings") {
                // This URL string directly opens the Accessibility pane.
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.borderedProminent)
            
            Text("After granting permission, please restart the application.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 400)
    }
}
