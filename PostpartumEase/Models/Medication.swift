import SwiftUI
import SwiftData

@Model
final class Medication {
    var name: String
    var dosage: String
    var frequency: FrequencyType
    var timeOfDay: Set<TimeOfDay>
    var notes: String?
    var startDate: Date
    var endDate: Date?
    var reminderEnabled: Bool
    var createdAt: Date
    var logs: [MedicationLog]
    
    init(
        name: String,
        dosage: String,
        frequency: FrequencyType,
        timeOfDay: Set<TimeOfDay> = [],
        notes: String? = nil,
        startDate: Date = Date(),
        endDate: Date? = nil,
        reminderEnabled: Bool = true
    ) {
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.timeOfDay = timeOfDay
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.reminderEnabled = reminderEnabled
        self.createdAt = Date()
        self.logs = []
    }
}

@Model
final class MedicationLog {
    var medication: Medication?
    var taken: Bool
    var scheduledTime: Date
    var takenTime: Date?
    var skipped: Bool
    var notes: String?
    var createdAt: Date
    
    init(
        medication: Medication? = nil,
        taken: Bool = false,
        scheduledTime: Date,
        takenTime: Date? = nil,
        skipped: Bool = false,
        notes: String? = nil
    ) {
        self.medication = medication
        self.taken = taken
        self.scheduledTime = scheduledTime
        self.takenTime = takenTime
        self.skipped = skipped
        self.notes = notes
        self.createdAt = Date()
    }
}

enum FrequencyType: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case asNeeded = "As Needed"
    case custom = "Custom"
}

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case bedtime = "Bedtime"
    
    var icon: String {
        switch self {
        case .morning: return "sunrise"
        case .afternoon: return "sun.max"
        case .evening: return "sunset"
        case .bedtime: return "moon.stars"
        }
    }
    
    var defaultTime: Date {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .morning:
            return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        case .afternoon:
            return calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? now
        case .evening:
            return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        case .bedtime:
            return calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) ?? now
        }
    }
} 