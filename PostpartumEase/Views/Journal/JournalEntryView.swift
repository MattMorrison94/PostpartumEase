import SwiftUI
import SwiftData

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var mood: Int?
    @State private var selectedTags: Set<JournalTag> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Write your thoughts...", text: $content, axis: .vertical)
                    .lineLimit(5...10)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            .padding()
        }
        .navigationTitle("New Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    // TODO: Implement save functionality
                    dismiss()
                }
                .bold()
                .disabled(content.isEmpty)
            }
        }
    }
} 