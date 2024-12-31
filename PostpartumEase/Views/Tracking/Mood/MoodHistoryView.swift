import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if moodEntries.isEmpty {
                ContentUnavailableView(
                    "No Mood Entries",
                    systemImage: "heart.slash",
                    description: Text("Start tracking your mood to see your history here.")
                )
            } else {
                List {
                    ForEach(moodEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                Text(moodDescription(for: entry.moodRating))
                                    .font(.headline)
                                Spacer()
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !entry.symptoms.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(entry.symptoms, id: \.self) { symptomTitle in
                                            if let symptom = PostpartumSymptom.allCases.first(where: { $0.rawValue == symptomTitle }) {
                                                HStack {
                                                    Image(systemName: symptom.icon)
                                                    Text(symptom.rawValue)
                                                }
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(.pink.opacity(0.1))
                                                .foregroundStyle(.pink)
                                                .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if let anxiety = entry.anxiety {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("Anxiety Level: \(anxiety)/5")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                            }
                            
                            if let sleep = entry.sleepQuality {
                                HStack {
                                    Image(systemName: "moon.stars")
                                    Text("Sleep Quality: \(sleep)/5")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.indigo)
                            }
                            
                            if let notes = entry.notes {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteMoodEntries)
                }
            }
        }
    }
    
    private func moodDescription(for rating: Int) -> String {
        switch rating {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Neutral"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Unknown"
        }
    }
    
    private func deleteMoodEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moodEntries[index])
        }
        try? modelContext.save()
    }
} 