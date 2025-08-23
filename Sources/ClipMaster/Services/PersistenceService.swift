import Foundation
import SwiftData

// Define a custom notification name for when the database changes.
extension Notification.Name {
    static let databaseDidChange = Notification.Name("databaseDidChange")
}

// Define a custom error for our service
enum PersistenceError: Error {
    case containerInitializationFailed
}

// Service for managing SwiftData.
@MainActor
class PersistenceService {
    private let modelContainer: ModelContainer
    private let historyLimit = 20 // Keep the 20 most recent items.
    
    var mainContext: ModelContext {
        modelContainer.mainContext
    }

    init() throws {
        do {
            let configuration = ModelConfiguration(for: ClipItem.self)
            self.modelContainer = try ModelContainer(for: ClipItem.self, configurations: configuration)
        } catch {
            throw PersistenceError.containerInitializationFailed
        }
    }
    
    // Method for adding a new item, handling duplicates and history limit.
    func addItem(_ item: ClipItem) {
        // 1. Fetch all items and check for duplicates in memory.
        // This is reliable and efficient for a small history limit.
        do {
            let allItems = try mainContext.fetch(FetchDescriptor<ClipItem>())
            if let existingItem = allItems.first(where: { $0.content == item.content }) {
                // If a duplicate is found, delete it.
                mainContext.delete(existingItem)
                print("[PersistenceService] Duplicate found. Deleting old one.")
            }
        } catch {
            print("Failed to fetch for duplicates: \(error)")
        }
        
        // 2. Insert the new item.
        mainContext.insert(item)
        
        // 3. Enforce the history limit.
        trimHistory()
        
        // 4. Save changes and notify the app.
        do {
            try mainContext.save()
            print("[PersistenceService] Item saved. Posting notification.")
            NotificationCenter.default.post(name: .databaseDidChange, object: nil)
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Deletes the oldest items if the history exceeds the limit.
    private func trimHistory() {
        do {
            let descriptor = FetchDescriptor<ClipItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let allItems = try mainContext.fetch(descriptor)
            
            if allItems.count > historyLimit {
                let itemsToDelete = allItems.dropFirst(historyLimit)
                for item in itemsToDelete {
                    print("[PersistenceService] Trimming old item.")
                    mainContext.delete(item)
                }
            }
        } catch {
            print("Failed to fetch items for trimming: \(error)")
        }
    }
}