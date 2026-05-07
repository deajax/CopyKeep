import SwiftUI

struct ClipboardListView: View {
    let items: [PasteboardItem]
    @Binding var selectedIndex: Int
    let onSelect: (PasteboardItem) -> Void

    // Body just renders — scrolling is driven externally via this callback.
    // Call `scrollToCurrent()` after keyboard-driven index changes.
    var scrollProxy: ScrollViewProxy?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        onSelect(item)
                    } label: {
                        ClipboardRowView(item: item, isSelected: index == selectedIndex)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering {
                            selectedIndex = index
                        }
                    }
                    .id(item.id)
                }
            }
            .padding(.horizontal, Constants.panelPaddingH)
            .padding(.vertical, 4)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
