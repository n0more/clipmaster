import Foundation
import SwiftUI

// A shared state object for the application.
// Marked as @MainActor to ensure thread-safe UI updates.
@MainActor
class AppState: ObservableObject {
    // Controls the visibility of the MenuBarExtra's content (the menu itself).
    @Published var isMenuPresented = false
    
    // Tracks whether we need to show the accessibility permission prompt.
    @Published var shouldShowAccessibilityAlert = false
}