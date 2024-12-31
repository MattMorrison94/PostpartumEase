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
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: config)
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
