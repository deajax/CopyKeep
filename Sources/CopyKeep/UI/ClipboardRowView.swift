import SwiftUI

struct ClipboardRowView: View {
    let item: PasteboardItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.contentType.sfSymbol)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(item.contentType.color.opacity(0.75))
                .frame(width: 18)

            Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundColor(.primary)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.accentColor.opacity(0.12))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 5))
    }
}
