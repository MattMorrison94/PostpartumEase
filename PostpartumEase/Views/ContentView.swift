import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TrackingView()
                .tabItem {
                    Label("Track", systemImage: "plus.circle.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            Text("Journal")
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
} 