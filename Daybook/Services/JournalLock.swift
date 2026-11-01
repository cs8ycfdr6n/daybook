import LocalAuthentication

enum JournalLock {
    enum Result {
        case unlocked
        case failed
        case unavailable
    }

    static func unlock() async -> Result {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .unavailable
        }
        do {
            let ok = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Daybook"
            )
            return ok ? .unlocked : .failed
        } catch {
            return .failed
        }
    }
}
