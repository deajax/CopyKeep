import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "clipboard")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.secondary.opacity(0.35))

            Text(Strings.emptyTitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))

            Text(Strings.emptyHint)
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
    }
}
