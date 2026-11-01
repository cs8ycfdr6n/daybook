import SwiftUI

struct LockView: View {
    var message: String?
    var unlock: () async -> Void

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            VStack(spacing: 22) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.tide)
                    .frame(width: 72, height: 88)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.paper)
                            .frame(width: 4, height: 52)
                            .padding(.leading, 16)
                    }
                Text("Daybook")
                    .font(.system(size: 40, weight: .medium, design: .serif))
                    .foregroundStyle(Color.ink)
                Text("Private on this iPhone.")
                    .font(.subheadline)
                    .foregroundStyle(Color.ink.opacity(0.62))
                if let message {
                    Text(message)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.ink.opacity(0.72))
                        .padding(.horizontal, 36)
                }
                Button {
                    Task { await unlock() }
                } label: {
                    Text("Unlock")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: 220)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.tide)
            }
        }
    }
}
