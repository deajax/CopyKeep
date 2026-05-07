import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(text.isEmpty ? 0.6 : 1)

            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($isFocused)
                .overlay(alignment: .leading) {
                    if text.isEmpty {
                        Text(Strings.searchPlaceholder)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary.opacity(0.6))
                            .allowsHitTesting(false)
                    }
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.primary.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
        }
        .animation(.easeOut(duration: 0.15), value: text.isEmpty)
    }
}
