import SwiftUI
import SwiftData

@Model
final class RecoveryEntry {
    var date: Date
    var symptoms: Set<PhysicalSymptom>
    var painLevel: Int? // 1-10 scale
    var bleeding: BleedingLevel?
    var medications: Set<String>
    var notes: String?
    var createdAt: Date
    
    init(
        date: Date = Date(),
        symptoms: Set<PhysicalSymptom> = [],
        painLevel: Int? = nil,
        bleeding: BleedingLevel? = nil,
        medications: Set<String> = [],
        notes: String? = nil
    ) {
        self.date = date
        self.symptoms = symptoms
        self.painLevel = painLevel
        self.bleeding = bleeding
        self.medications = medications
        self.notes = notes
        self.createdAt = Date()
    }
}

enum PhysicalSymptom: String, Codable, CaseIterable {
    case incisionPain = "Incision Pain"
    case breastPain = "Breast Pain"
    case cramping = "Cramping"
    case backPain = "Back Pain"
    case pelvicPain = "Pelvic Pain"
    case headache = "Headache"
    case swelling = "Swelling"
    case fatigue = "Fatigue"
    case constipation = "Constipation"
    case hemorrhoids = "Hemorrhoids"
    
    var icon: String {
        switch self {
        case .incisionPain: return "cross.circle"
        case .breastPain: return "heart.circle"
        case .cramping: return "waveform"
        case .backPain: return "figure.walk"
        case .pelvicPain: return "figure.seated"
        case .headache: return "brain.head.profile"
        case .swelling: return "arrow.up.circle"
        case .fatigue: return "zzz"
        case .constipation: return "stomach"
        case .hemorrhoids: return "circle.circle"
        }
    }
}

enum BleedingLevel: String, Codable, CaseIterable {
    case none = "None"
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .light: return .pink
        case .moderate: return .red
        case .heavy: return .red.opacity(0.8)
        }
    }
} 