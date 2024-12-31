import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var selectedCategory: HistoryCategory = .mood
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(HistoryCategory.allCases) { category in
                        Text(category.title)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                Group {
                    switch selectedCategory {
                    case .mood:
                        MoodHistoryView()
                    case .recovery:
                        Text("Recovery History")
                    case .selfCare:
                        Text("Self Care History")
                    case .sleep:
                        Text("Sleep History")
                    case .medication:
                        Text("Medication History")
                    case .feeding:
                        Text("Feeding History")
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

enum HistoryCategory: String, CaseIterable, Identifiable {
    case mood = "Mood"
    case recovery = "Recovery"
    case selfCare = "Self Care"
    case sleep = "Sleep"
    case medication = "Medication"
    case feeding = "Feeding"
    
    var id: String { rawValue }
    var title: String { rawValue }
} 