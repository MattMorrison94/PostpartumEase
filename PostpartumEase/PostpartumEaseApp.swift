//
//  PostpartumEaseApp.swift
//  PostpartumEase
//
//  Created by Matthew Morrison on 30/12/2024.
//

import SwiftUI
import SwiftData

@main
struct PostpartumEaseApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([MoodEntry.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none  // Explicitly disable CloudKit
            )
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            print("Failed to initialize ModelContainer: \(error.localizedDescription)")
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
