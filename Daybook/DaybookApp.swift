import SwiftData
import SwiftUI

@main
struct DaybookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
