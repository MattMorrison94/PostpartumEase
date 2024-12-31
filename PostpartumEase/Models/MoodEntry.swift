import SwiftUI
import SwiftData

@Model
final class MoodEntry {
    var date: Date = Date()
    var moodRating: Int = 0 // 1-5 scale
    var symptoms: [String] = [] // Store symptom raw values as strings
    var anxiety: Int? // 1-5 scale
    var sleepQuality: Int? // 1-5 scale
    var notes: String?
    var createdAt: Date = Date()
    
    init(
        date: Date = Date(),
        moodRating: Int,
        symptoms: Set<PostpartumSymptom> = [],
        anxiety: Int? = nil,
        sleepQuality: Int? = nil,
        notes: String? = nil
    ) {
        self.date = date
        self.moodRating = moodRating
        self.symptoms = Array(symptoms).map { $0.rawValue }
        self.anxiety = anxiety
        self.sleepQuality = sleepQuality
        self.notes = notes
        self.createdAt = Date()
    }
    
    convenience init() {
        self.init(date: Date(), moodRating: 0, symptoms: [])
    }
}

enum PostpartumSymptom: String, CaseIterable {
    case sadness = "Feeling Sad"
    case anxiety = "Anxiety"
    case overwhelmed = "Feeling Overwhelmed"
    case crying = "Crying Spells"
    case irritability = "Irritability"
    case sleepIssues = "Sleep Problems"
    case appetiteChanges = "Appetite Changes"
    case concentration = "Difficulty Concentrating"
    case worthlessness = "Feelings of Worthlessness"
    case disconnected = "Feeling Disconnected"
    
    var icon: String {
        switch self {
        case .sadness: return "cloud.rain"
        case .anxiety: return "heart.circle"
        case .overwhelmed: return "tornado"
        case .crying: return "drop"
        case .irritability: return "bolt"
        case .sleepIssues: return "moon.zzz"
        case .appetiteChanges: return "fork.knife"
        case .concentration: return "brain"
        case .worthlessness: return "heart.slash"
        case .disconnected: return "person.crop.circle.badge.questionmark"
        }
    }
} 