import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var clipItems: [ClipItem] = []
    
    private let modelContext: ModelContext
    private let clipboardService: ClipboardService
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext, clipboardService: ClipboardService) {
        self.modelContext = modelContext
        self.clipboardService = clipboardService
        fetchHistory()
        
        // Listen for notifications that the database has changed.
        NotificationCenter.default
            .publisher(for: .databaseDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("[HistoryViewModel] Received database change notification. Fetching history.")
                self?.fetchHistory()
            }
            .store(in: &cancellables)
    }
    
    func fetchHistory() {
        do {
            let descriptor = FetchDescriptor<ClipItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            clipItems = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch clip items: \(error)")
        }
    }
    
    func copyToPasteboard(item: ClipItem) {
        clipboardService.pauseMonitoring()
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        if item.contentType == "public.png" {
            pasteboard.setData(item.content, forType: .png)
        } else {
            if let text = String(data: item.content, encoding: .utf8) {
                pasteboard.setString(text, forType: .string)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.clipboardService.resumeMonitoring()
        }
    }
}
