import SwiftUI
import SwiftData

@Model
final class JournalEntry {
    var date: Date
    var content: String
    var mood: Int? // 1-5 scale
    var tags: Set<JournalTag>
    var images: [Data]?
    var createdAt: Date
    var lastModified: Date
    
    init(
        date: Date = Date(),
        content: String,
        mood: Int? = nil,
        tags: Set<JournalTag> = [],
        images: [Data]? = nil
    ) {
        self.date = date
        self.content = content
        self.mood = mood
        self.tags = tags
        self.images = images
        self.createdAt = Date()
        self.lastModified = Date()
    }
}

enum JournalTag: String, Codable, CaseIterable {
    case milestone = "Milestone"
    case gratitude = "Gratitude"
    case challenge = "Challenge"
    case victory = "Victory"
    case reflection = "Reflection"
    case goal = "Goal"
    case memory = "Memory"
    case support = "Support"
    
    var icon: String {
        switch self {
        case .milestone: return "flag.circle"
        case .gratitude: return "heart.circle"
        case .challenge: return "mountain.2"
        case .victory: return "star"
        case .reflection: return "thought.bubble"
        case .goal: return "target"
        case .memory: return "camera"
        case .support: return "hand.raised"
        }
    }
    
    var color: Color {
        switch self {
        case .milestone: return .blue
        case .gratitude: return .pink
        case .challenge: return .orange
        case .victory: return .yellow
        case .reflection: return .purple
        case .goal: return .green
        case .memory: return .cyan
        case .support: return .mint
        }
    }
} 