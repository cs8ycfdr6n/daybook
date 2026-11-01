import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var unlocked = false
    @State private var lockMessage: String?

    var body: some View {
        Group {
            if unlocked {
                FeedView(lock: { unlocked = false })
            } else {
                LockView(message: lockMessage) {
                    await attemptUnlock()
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // Face ID itself moves the app to inactive. Only a real background locks it.
            if phase == .background {
                unlocked = false
                lockMessage = nil
            }
        }
    }

    private func attemptUnlock() async {
        switch await JournalLock.unlock() {
        case .unlocked:
            lockMessage = nil
            unlocked = true
        case .failed:
            lockMessage = "Face ID or the passcode was not accepted."
        case .unavailable:
            lockMessage = "This device has no passcode, so the lock cannot arm. Set a passcode to protect Daybook. Continuing for now."
            unlocked = true
        }
    }
}
