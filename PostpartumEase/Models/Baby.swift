import SwiftUI
import SwiftData

@Model
final class Baby {
    var name: String
    var birthDate: Date
    var birthWeight: Double?
    var birthLength: Double?
    var gender: Gender
    var createdAt: Date
    var lastModified: Date
    
    init(
        name: String,
        birthDate: Date,
        birthWeight: Double? = nil,
        birthLength: Double? = nil,
        gender: Gender
    ) {
        self.name = name
        self.birthDate = birthDate
        self.birthWeight = birthWeight
        self.birthLength = birthLength
        self.gender = gender
        self.createdAt = Date()
        self.lastModified = Date()
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
} 