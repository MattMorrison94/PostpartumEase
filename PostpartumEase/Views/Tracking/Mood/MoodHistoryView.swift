import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var moodEntries: [MoodEntry]
    @State private var selectedEntry: MoodEntry?
    @State private var showDeleteAlert = false
    @State private var entryToDelete: IndexSet?
    
    init() {
        let sortDescriptor = SortDescriptor<MoodEntry>(\.date, order: .reverse)
        let descriptor = FetchDescriptor<MoodEntry>(sortBy: [sortDescriptor])
        _moodEntries = Query(descriptor)
    }
    
    var body: some View {
        Group {
            if moodEntries.isEmpty {
                ContentUnavailableView(
                    "No Mood Entries",
                    systemImage: "heart.slash",
                    description: Text("Start tracking your mood to see your history here.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(moodEntries) { entry in
                            MoodHistoryCard(entry: entry)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedEntry = entry
                                    }
                                }
                        }
                        .onDelete(perform: confirmDelete)
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            NavigationStack {
                MoodInsightView(entry: entry)
            }
            .presentationDragIndicator(.visible)
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let offsets = entryToDelete {
                    deleteMoodEntries(at: offsets)
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func confirmDelete(at offsets: IndexSet) {
        entryToDelete = offsets
        showDeleteAlert = true
    }
    
    private func deleteMoodEntries(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(moodEntries[index])
            }
            try? modelContext.save()
        }
    }
}

struct MoodHistoryCard: View {
    let entry: MoodEntry
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with mood and time
            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(moodColor(for: entry.moodRating).gradient)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                    
                    Text(moodDescription(for: entry.moodRating))
                        .font(.title3.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.bold())
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Symptoms
            if !entry.symptoms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.symptoms, id: \.self) { symptomTitle in
                            if let symptom = PostpartumSymptom.allCases.first(where: { $0.rawValue == symptomTitle }) {
                                SymptomTag(symptom: symptom)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Metrics
            if entry.anxiety != nil || entry.sleepQuality != nil {
                HStack(spacing: 16) {
                    if let anxiety = entry.anxiety {
                        MetricView(
                            icon: "brain.head.profile",
                            color: .orange,
                            title: "Anxiety",
                            value: anxiety,
                            maxValue: 5
                        )
                    }
                    
                    if let sleep = entry.sleepQuality {
                        MetricView(
                            icon: "moon.stars",
                            color: .indigo,
                            title: "Sleep",
                            value: sleep,
                            maxValue: 5
                        )
                    }
                }
                .font(.subheadline)
            }
            
            // Notes preview if available
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        }
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .mint
        case 5: return .green
        default: return .gray
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
}

struct SymptomTag: View {
    let symptom: PostpartumSymptom
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symptom.icon)
            Text(symptom.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.pink.opacity(0.1))
        .foregroundStyle(.pink)
        .clipShape(Capsule())
    }
}

struct MetricView: View {
    let icon: String
    let color: Color
    let title: String
    let value: Int
    let maxValue: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            
            HStack(spacing: 4) {
                ForEach(1...maxValue, id: \.self) { index in
                    Circle()
                        .fill(index <= value ? color : color.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .foregroundStyle(color)
    }
}

struct MoodInsightView: View {
    let entry: MoodEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Mood Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(moodColor(for: entry.moodRating).gradient)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: moodColor(for: entry.moodRating).opacity(0.3), radius: 8, y: 4)
                    
                    VStack(spacing: 8) {
                        Text(moodDescription(for: entry.moodRating))
                            .font(.title.bold())
                        
                        Text(entry.date.formatted(date: .complete, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Symptoms Section
                if !entry.symptoms.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Symptoms")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(entry.symptoms, id: \.self) { symptomTitle in
                                if let symptom = PostpartumSymptom.allCases.first(where: { $0.rawValue == symptomTitle }) {
                                    SymptomTag(symptom: symptom)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Metrics Section
                if entry.anxiety != nil || entry.sleepQuality != nil {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Metrics")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            if let anxiety = entry.anxiety {
                                MetricDetailView(
                                    icon: "brain.head.profile",
                                    color: .orange,
                                    title: "Anxiety Level",
                                    value: anxiety,
                                    maxValue: 5
                                )
                            }
                            
                            if let sleep = entry.sleepQuality {
                                MetricDetailView(
                                    icon: "moon.stars",
                                    color: .indigo,
                                    title: "Sleep Quality",
                                    value: sleep,
                                    maxValue: 5
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Notes Section
                if let notes = entry.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("Mood Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .mint
        case 5: return .green
        default: return .gray
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
}

struct MetricDetailView: View {
    let icon: String
    let color: Color
    let title: String
    let value: Int
    let maxValue: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(1...maxValue, id: \.self) { index in
                        Circle()
                            .fill(index <= value ? color : color.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
            
            Text("\(value)/\(maxValue)")
                .font(.headline)
                .foregroundStyle(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? .infinity,
            height: rows.last?.maxY ?? 0
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for row in rows {
            for element in row.elements {
                element.view.place(
                    at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(width: element.width, height: element.height)
                )
            }
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row(y: 0)
        var x: CGFloat = 0
        var maxY: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))
            
            if x + size.width > (proposal.width ?? .infinity) {
                rows.append(currentRow)
                currentRow = Row(y: maxY + spacing)
                x = 0
            }
            
            currentRow.elements.append(Element(view: subview, x: x, width: size.width, height: size.height))
            x += size.width + spacing
            maxY = max(maxY, currentRow.y + size.height)
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var y: CGFloat
        var elements: [Element] = []
        
        var maxY: CGFloat {
            y + (elements.map(\.height).max() ?? 0)
        }
    }
    
    private struct Element {
        let view: LayoutSubview
        let x: CGFloat
        let width: CGFloat
        let height: CGFloat
    }
} 