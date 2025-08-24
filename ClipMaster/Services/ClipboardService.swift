import AppKit
import Foundation

// Service for monitoring the clipboard
@MainActor
class ClipboardService {
    private let pasteboard = NSPasteboard.general
    private let persistenceService: PersistenceService
    private var timer: Timer?
    private var lastChangeCount: Int
    
    // A flag to temporarily ignore pasteboard changes.
    private var isMonitoringPaused = false

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
        self.lastChangeCount = pasteboard.changeCount
    }

    // Start monitoring
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task {
                await self?.checkPasteboard()
            }
        }
    }

    // Stop monitoring
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    // Public methods to pause and resume monitoring.
    func pauseMonitoring() {
        isMonitoringPaused = true
        print("[ClipboardService] Monitoring paused.")
    }
    
    func resumeMonitoring() {
        // Update the change count to the latest, so we don't re-copy what we just set.
        lastChangeCount = pasteboard.changeCount
        isMonitoringPaused = false
        print("[ClipboardService] Monitoring resumed.")
    }

    private func checkPasteboard() {
        // Ignore changes if monitoring is paused.
        guard !isMonitoringPaused else { return }
        
        // Check if the clipboard has changed since the last check
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        
        print("[ClipboardService] Change detected. Change count: \(pasteboard.changeCount)")
        lastChangeCount = pasteboard.changeCount

        // We check the pasteboard's types to decide what to copy.
        guard let availableTypes = pasteboard.types else {
            print("[ClipboardService] No types available on pasteboard.")
            return
        }
        
        print("[ClipboardService] Available types: \(availableTypes.map { $0.rawValue })")

        if availableTypes.contains(.png) {
            if let data = pasteboard.data(forType: .png) {
                print("[ClipboardService] Saving PNG image (\(data.count) bytes).")
                let newItem = ClipItem(content: data, contentType: "public.png")
                persistenceService.addItem(newItem)
                return
            }
        }
        
        if availableTypes.contains(.string) {
            if let text = pasteboard.string(forType: .string), !text.isEmpty {
                print("[ClipboardService] Saving text: \(text)")
                let newItem = ClipItem(content: Data(text.utf8), contentType: "public.utf8-plain-text")
                persistenceService.addItem(newItem)
                return
            }
        }
        
        print("[ClipboardService] No supported content type found.")
    }
}

// Helper extension for NSImage to easily convert to PNG
extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
