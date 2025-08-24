import SwiftUI

struct SetTemperatureView: View {
    // We receive the service as an environment object.
    @EnvironmentObject var settingsService: SettingsService
    
    // A local state to bind the slider to.
    @State private var temperature: Double
    
    var onDone: () -> Void
    
    init(initialTemperature: Double, onDone: @escaping () -> Void) {
        _temperature = State(initialValue: initialTemperature)
        self.onDone = onDone
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Set Ollama Temperature")
                .font(.headline)
            
            Text("Lower values are more deterministic, higher values are more creative.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Display the current value.
            Text(String(format: "%.2f", temperature))
                .font(.system(.title, design: .monospaced))
            
            // Slider for changing the temperature.
            Slider(value: $temperature, in: 0.0...2.0, step: 0.05)
            
            Button("Done", action: {
                // When done, update the service and close the window.
                settingsService.setTemperature(temperature)
                onDone()
            })
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 300)
    }
}
