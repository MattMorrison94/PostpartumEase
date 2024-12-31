import SwiftUI
import SwiftData

struct MoodTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MoodTrackingViewModel()
    
    private let moodLevels = 5
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                moodRatingSection
                symptomsSection
                additionalMetricsSection
                notesSection
            }
            .padding()
        }
        .navigationTitle("Track Mood")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.saveMoodEntry()
                        dismiss()
                    }
                }
                .bold()
                .disabled(!viewModel.isValid)
            }
        }
        .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.error) { _ in
            Button("OK") {}
        } message: { error in
            Text(error.localizedDescription)
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
    
    private var moodRatingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(1...moodLevels, id: \.self) { level in
                    moodRatingButton(for: level)
                }
            }
            .padding(.vertical)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private func moodRatingButton(for level: Int) -> some View {
        VStack {
            Button {
                viewModel.moodRating = level
            } label: {
                VStack {
                    Image(systemName: level <= viewModel.moodRating ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundStyle(level <= viewModel.moodRating ? .pink : .gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            Text(viewModel.moodDescription(for: level))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptoms")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(PostpartumSymptom.allCases, id: \.self) { symptom in
                    SymptomButton(
                        title: symptom.rawValue,
                        icon: symptom.icon,
                        isSelected: viewModel.selectedSymptoms.contains(symptom)
                    ) {
                        viewModel.toggleSymptom(symptom)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var additionalMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Metrics")
                .font(.headline)
            
            VStack(spacing: 16) {
                anxietyLevelPicker
                sleepQualityPicker
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private var anxietyLevelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anxiety Level")
                .font(.subheadline)
            
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(level <= (viewModel.anxietyLevel ?? 0) ? Color.orange : Color.gray.opacity(0.3))
                        .frame(height: 30)
                        .overlay {
                            Text("\(level)")
                                .foregroundStyle(level <= (viewModel.anxietyLevel ?? 0) ? .white : .secondary)
                        }
                        .onTapGesture {
                            viewModel.anxietyLevel = level
                        }
                }
            }
        }
    }
    
    private var sleepQualityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sleep Quality")
                .font(.subheadline)
            
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Image(systemName: level <= (viewModel.sleepQuality ?? 0) ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(level <= (viewModel.sleepQuality ?? 0) ? .yellow : .gray)
                        .onTapGesture {
                            viewModel.sleepQuality = level
                        }
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            TextField("Add any additional notes...", text: $viewModel.notes, axis: .vertical)
                .lineLimit(4...6)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct SymptomButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundStyle(isSelected ? .pink : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
} 