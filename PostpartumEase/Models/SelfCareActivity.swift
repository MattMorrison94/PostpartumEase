import SwiftUI
import SwiftData

@Model
final class SelfCareActivity {
    var type: ActivityType
    var startTime: Date
    var duration: TimeInterval
    var notes: String?
    var mood: Int? // 1-5 scale
    var createdAt: Date
    
    init(
        type: ActivityType,
        startTime: Date = Date(),
        duration: TimeInterval,
        notes: String? = nil,
        mood: Int? = nil
    ) {
        self.type = type
        self.startTime = startTime
        self.duration = duration
        self.notes = notes
        self.mood = mood
        self.createdAt = Date()
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case meditation = "Meditation"
    case exercise = "Exercise"
    case shower = "Shower"
    case nap = "Nap"
    case reading = "Reading"
    case outdoors = "Time Outdoors"
    case hobby = "Hobby"
    case socializing = "Socializing"
    case pelvicFloor = "Pelvic Floor Exercise"
    case breathing = "Breathing Exercise"
    
    var icon: String {
        switch self {
        case .meditation: return "brain.head.profile"
        case .exercise: return "figure.walk"
        case .shower: return "drop.circle"
        case .nap: return "bed.double"
        case .reading: return "book"
        case .outdoors: return "sun.max"
        case .hobby: return "heart"
        case .socializing: return "person.2"
        case .pelvicFloor: return "figure.core.training"
        case .breathing: return "lungs"
        }
    }
    
    var color: Color {
        switch self {
        case .meditation: return .purple
        case .exercise: return .green
        case .shower: return .blue
        case .nap: return .indigo
        case .reading: return .orange
        case .outdoors: return .yellow
        case .hobby: return .pink
        case .socializing: return .mint
        case .pelvicFloor: return .teal
        case .breathing: return .cyan
        }
    }
} 