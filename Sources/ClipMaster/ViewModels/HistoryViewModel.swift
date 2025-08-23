import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var clipItems: [ClipItem] = []
    @Published var isProcessingOllama: Bool = false // To show a loading indicator
    
    private let modelContext: ModelContext
    private let clipboardService: ClipboardService
    private let ollamaService: OllamaService
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext, clipboardService: ClipboardService, ollamaService: OllamaService) {
        self.modelContext = modelContext
        self.clipboardService = clipboardService
        self.ollamaService = ollamaService
        fetchHistory()
        
        NotificationCenter.default
            .publisher(for: .databaseDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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
    
    func processWithOllama(item: ClipItem) async {
        guard item.contentType != "public.png",
              let text = String(data: item.content, encoding: .utf8) else {
            return
        }
        
        isProcessingOllama = true
        
        do {
            let result = try await ollamaService.generate(prompt: text)
            
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(result, forType: .string)
            
        } catch {
            print("Error processing with Ollama: \(error)")
        }
        
        isProcessingOllama = false
    }
}