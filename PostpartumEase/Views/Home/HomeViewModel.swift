import SwiftUI
import SwiftData
import CloudKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var latestMood: MoodEntry?
    @Published var latestRecovery: RecoveryEntry?
    @Published var latestSelfCare: SelfCareActivity?
    @Published var recentActivities: [RecentActivity] = []
    @Published var recoveryMilestones: [RecoveryMilestone] = []
    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: ActiveSheet?
    
    private var modelContext: ModelContext?
    private let cloudKitContainer: CKContainer?
    
    var daysPostpartum: Int {
        guard let user = user else { return 0 }
        return Calendar.current.dateComponents([.day], from: user.deliveryDate, to: Date()).day ?? 0
    }
    
    init() {
        // Initialize CloudKit container if available
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            self.cloudKitContainer = CKContainer(identifier: "iCloud.\(bundleIdentifier)")
        } else {
            self.cloudKitContainer = nil
        }
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func refreshData() async {
        guard let modelContext = modelContext else { return }
        
        await loadUser()
        await fetchLatestEntries()
        await syncWithCloudKit()
        loadRecentActivities()
    }
    
    private func loadUser() async {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        user = try? modelContext.fetch(descriptor).first
    }
    
    private func fetchLatestEntries() async {
        guard let modelContext = modelContext else { return }
        
        // Fetch latest mood entry
        var moodDescriptor = FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        moodDescriptor.fetchLimit = 1
        latestMood = try? modelContext.fetch(moodDescriptor).first
        
        // Fetch latest recovery entry
        var recoveryDescriptor = FetchDescriptor<RecoveryEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        recoveryDescriptor.fetchLimit = 1
        latestRecovery = try? modelContext.fetch(recoveryDescriptor).first
        
        // Fetch latest self-care activity
        var selfCareDescriptor = FetchDescriptor<SelfCareActivity>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        selfCareDescriptor.fetchLimit = 1
        latestSelfCare = try? modelContext.fetch(selfCareDescriptor).first
    }
    
    private func syncWithCloudKit() async {
        // Implement CloudKit sync logic here
    }
    
    private func loadRecentActivities() {
        // This would be replaced with actual data from your models
        recentActivities = []
    }
    
    private func setupRecoveryMilestones() {
        recoveryMilestones = [
            RecoveryMilestone(title: "First Week Complete", completed: daysPostpartum >= 7),
            RecoveryMilestone(title: "Two Weeks Milestone", completed: daysPostpartum >= 14),
            RecoveryMilestone(title: "One Month Achievement", completed: daysPostpartum >= 30),
            RecoveryMilestone(title: "Six Weeks Recovery", completed: daysPostpartum >= 42),
            RecoveryMilestone(title: "Two Months Journey", completed: daysPostpartum >= 60)
        ]
    }
    
    func moodDescription(for rating: Int) -> String {
        switch rating {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Neutral"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Unknown"
        }
    }
    
    // Navigation actions
    func trackMood() {
        activeSheet = .mood
    }
    
    func trackRecovery() {
        activeSheet = .recovery
    }
    
    func trackSelfCare() {
        activeSheet = .selfCare
    }
    
    func openJournal() {
        activeSheet = .journal
    }
    
    func dismissSheet() {
        activeSheet = nil
        Task {
            await refreshData()
        }
    }
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let title: String
    let timestamp: Date
    let icon: String
    let color: Color
}

struct RecoveryMilestone {
    let title: String
    let completed: Bool
}

enum ActiveSheet: Identifiable {
    case mood
    case recovery
    case selfCare
    case journal
    
    var id: Int {
        switch self {
        case .mood: return 1
        case .recovery: return 2
        case .selfCare: return 3
        case .journal: return 4
        }
    }
} 