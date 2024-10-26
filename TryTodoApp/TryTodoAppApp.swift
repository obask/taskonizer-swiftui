import SwiftUI
import SwiftData

@main
struct TryTodoAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer) // Set modelContainer in environment
        }
    }
}
