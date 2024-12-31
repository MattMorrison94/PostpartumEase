import SwiftUI
import SwiftData

@MainActor
class MoodTrackingViewModel: ObservableObject {
    @Published var moodRating: Int = 0
    @Published var selectedSymptoms: Set<PostpartumSymptom> = []
    @Published var anxietyLevel: Int?
    @Published var sleepQuality: Int?
    @Published var notes: String = ""
    @Published var showError = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    var isValid: Bool {
        moodRating > 0
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func toggleSymptom(_ symptom: PostpartumSymptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
    
    func moodDescription(for rating: Int) -> String {
        switch rating {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Neutral"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Select"
        }
    }
    
    func saveMoodEntry() async {
        guard let modelContext = modelContext else {
            error = NSError(domain: "PostpartumEase", code: 0, userInfo: [NSLocalizedDescriptionKey: "Model context not available"])
            showError = true
            return
        }
        
        do {
            let entry = MoodEntry(
                date: Date(),
                moodRating: moodRating,
                symptoms: selectedSymptoms,
                anxiety: anxietyLevel,
                sleepQuality: sleepQuality,
                notes: notes.isEmpty ? nil : notes
            )
            
            modelContext.insert(entry)
            try modelContext.save()
            
        } catch {
            self.error = error
            self.showError = true
        }
    }
} 