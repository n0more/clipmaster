import Foundation
import SwiftData

@Model
public final class ClipItem {
    // A unique identifier for each item
    @Attribute(.unique) public var id: UUID
    
    // The clipboard content. Stored as Data
    // to support both text and images.
    public var content: Data
    
    // The content type, so we know how to interpret it (text or image).
    // We use a string for simplicity, e.g., "public.utf8-plain-text" or "public.png".
    public var contentType: String
    
    // The date and time of copying for sorting and display.
    public var createdAt: Date
    
    public init(content: Data, contentType: String) {
        self.id = UUID()
        self.content = content
        self.contentType = contentType
        self.createdAt = .now
    }
}
