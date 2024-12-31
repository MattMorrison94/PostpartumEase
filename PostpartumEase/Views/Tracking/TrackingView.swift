import SwiftUI
import SwiftData

struct TrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedActivity: TrackingActivity?
    @State private var showActivitySheet = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(TrackingActivity.allCases) { activity in
                    Button {
                        selectedActivity = activity
                        showActivitySheet = true
                    } label: {
                        TrackingActivityCard(activity: activity)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Track")
        .sheet(isPresented: $showActivitySheet) {
            if let activity = selectedActivity {
                NavigationStack {
                    Group {
                        switch activity {
                        case .mood:
                            MoodTrackingView()
                        case .recovery:
                            RecoveryTrackingView()
                        case .selfCare:
                            SelfCareTrackingView()
                        case .sleep:
                            SleepTrackingView()
                        case .medication:
                            MedicationTrackingView()
                        case .feeding:
                            FeedingTrackingView()
                        }
                    }
                }
            }
        }
    }
}

struct TrackingActivityCard: View {
    let activity: TrackingActivity
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.title)
                .foregroundStyle(activity.color)
            
            VStack(spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

enum TrackingActivity: String, CaseIterable, Identifiable {
    case mood = "Mood"
    case recovery = "Recovery"
    case selfCare = "Self Care"
    case sleep = "Sleep"
    case medication = "Medication"
    case feeding = "Feeding"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .mood:
            return "Track your emotional wellbeing"
        case .recovery:
            return "Monitor physical recovery"
        case .selfCare:
            return "Log self-care activities"
        case .sleep:
            return "Record sleep patterns"
        case .medication:
            return "Manage medications"
        case .feeding:
            return "Track feeding sessions"
        }
    }
    
    var icon: String {
        switch self {
        case .mood:
            return "heart.fill"
        case .recovery:
            return "cross.circle.fill"
        case .selfCare:
            return "sparkles"
        case .sleep:
            return "moon.zzz.fill"
        case .medication:
            return "pills.fill"
        case .feeding:
            return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .mood:
            return .pink
        case .recovery:
            return .blue
        case .selfCare:
            return .purple
        case .sleep:
            return .indigo
        case .medication:
            return .green
        case .feeding:
            return .orange
        }
    }
} 