import SwiftUI
import SwiftData

@Model
final class User {
    var name: String
    var birthDate: Date
    var deliveryDate: Date
    var deliveryType: DeliveryType?
    var profileImage: Data?
    var createdAt: Date
    var lastModified: Date
    
    @Relationship(deleteRule: .cascade) var moodEntries: [MoodEntry]
    @Relationship(deleteRule: .cascade) var recoveryEntries: [RecoveryEntry]
    @Relationship(deleteRule: .cascade) var selfCareActivities: [SelfCareActivity]
    @Relationship(deleteRule: .cascade) var medications: [Medication]
    @Relationship(deleteRule: .cascade) var journalEntries: [JournalEntry]
    
    init(
        name: String,
        birthDate: Date,
        deliveryDate: Date,
        deliveryType: DeliveryType? = nil,
        profileImage: Data? = nil
    ) {
        self.name = name
        self.birthDate = birthDate
        self.deliveryDate = deliveryDate
        self.deliveryType = deliveryType
        self.profileImage = profileImage
        self.createdAt = Date()
        self.lastModified = Date()
        self.moodEntries = []
        self.recoveryEntries = []
        self.selfCareActivities = []
        self.medications = []
        self.journalEntries = []
    }
}

enum DeliveryType: String, Codable, CaseIterable {
    case vaginal = "Vaginal Birth"
    case cesarean = "C-Section"
} 