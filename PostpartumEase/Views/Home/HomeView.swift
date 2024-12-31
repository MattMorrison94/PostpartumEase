import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeCard
                    quickActionsCard
                    dailyInsightsCard
                    recoveryProgressCard
                    recentActivitiesCard
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                Task {
                    await viewModel.refreshData()
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                Task {
                    await viewModel.refreshData()
                }
            }
            .sheet(item: $viewModel.activeSheet) { sheet in
                NavigationStack {
                    Group {
                        switch sheet {
                        case .mood:
                            MoodTrackingView()
                        case .recovery:
                            Text("Recovery Tracking")
                                .navigationTitle("Track Recovery")
                        case .selfCare:
                            Text("Self Care Tracking")
                                .navigationTitle("Track Self Care")
                        case .journal:
                            JournalEntryView()
                                .environment(\.modelContext, modelContext)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if case .mood = sheet {} else {
                                Button("Done") {
                                    viewModel.dismissSheet()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let profileImage = viewModel.user?.profileImage,
                   let uiImage = UIImage(data: profileImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(.secondary.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                        }
                }
                
                VStack(alignment: .leading) {
                    Text("Welcome back,")
                        .foregroundStyle(.secondary)
                    Text(viewModel.user?.name ?? "")
                        .font(.title2)
                        .bold()
                }
            }
            
            Text("Day \(viewModel.daysPostpartum) of your postpartum journey")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "Track Mood",
                    icon: "heart.fill",
                    color: .pink
                ) {
                    viewModel.trackMood()
                }
                
                QuickActionButton(
                    title: "Track Recovery",
                    icon: "cross.circle.fill",
                    color: .blue
                ) {
                    viewModel.trackRecovery()
                }
                
                QuickActionButton(
                    title: "Self Care",
                    icon: "sparkles",
                    color: .purple
                ) {
                    viewModel.trackSelfCare()
                }
                
                QuickActionButton(
                    title: "Journal",
                    icon: "book.fill",
                    color: .orange
                ) {
                    viewModel.openJournal()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var dailyInsightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Insights")
                .font(.headline)
            
            if let mood = viewModel.latestMood,
               Calendar.current.isDateInToday(mood.date) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                    Text("Mood: \(viewModel.moodDescription(for: mood.moodRating))")
                }
            }
            
            if let recovery = viewModel.latestRecovery,
               Calendar.current.isDateInToday(recovery.date) {
                HStack {
                    Image(systemName: "cross.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Pain Level: \(recovery.painLevel ?? 0)/10")
                }
            }
            
            if let selfCare = viewModel.latestSelfCare,
               Calendar.current.isDateInToday(selfCare.startTime) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.purple)
                    Text("\(selfCare.type.rawValue) for \(Int(selfCare.duration / 60)) min")
                }
            }
            
            if viewModel.latestMood == nil || !Calendar.current.isDateInToday(viewModel.latestMood?.date ?? Date()) {
                Text("No entries for today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var recoveryProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery Progress")
                .font(.headline)
            
            ForEach(viewModel.recoveryMilestones, id: \.title) { milestone in
                HStack {
                    Image(systemName: milestone.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(milestone.completed ? .green : .secondary)
                    Text(milestone.title)
                        .foregroundStyle(milestone.completed ? .primary : .secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var recentActivitiesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activities")
                .font(.headline)
            
            if viewModel.recentActivities.isEmpty {
                Text("No recent activities")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentActivities) { activity in
                    HStack {
                        Image(systemName: activity.icon)
                            .foregroundStyle(activity.color)
                        
                        VStack(alignment: .leading) {
                            Text(activity.title)
                            Text(activity.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    } }
