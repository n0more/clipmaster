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
    
    func addItem(_ item: ClipItem) {
        mainContext.insert(item)
        
        do {
            try mainContext.save()
            print("[PersistenceService] Item saved. Posting notification.")
            // Post a notification on the main thread after a successful save.
            NotificationCenter.default.post(name: .databaseDidChange, object: nil)
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}