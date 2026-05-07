import SwiftUI

struct PanelContent: View {
    @ObservedObject var viewModel: ClipboardViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var selectedIndex: Int = 0
    @State private var keyboardScrollTarget: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header: search + type filter
            VStack(spacing: 8) {
                SearchBar(text: $viewModel.searchText, isFocused: _isSearchFocused)
                    .padding(.horizontal, Constants.panelPaddingH)

                typeFilterBar
                    .padding(.horizontal, Constants.panelPaddingH)
            }
            .padding(.top, 10)
            .padding(.bottom, 8)

            // Subtle separator
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 1)

            // Content area
            if viewModel.filteredItems.isEmpty {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 32)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                                Button {
                                    viewModel.selectItem(item)
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
                    .onChange(of: keyboardScrollTarget) { _, target in
                        guard let target,
                              let id = viewModel.filteredItems[safe: target]?.id
                        else { return }
                        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.85)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }

            // Footer hint
            footerView
        }
        .frame(width: Constants.panelWidth)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.radiusLG)
                    .fill(.ultraThickMaterial)

                RoundedRectangle(cornerRadius: Constants.radiusLG)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
            }
        }
        .onAppear {
            isSearchFocused = true
        }
        .onChange(of: viewModel.searchText) { _, _ in
            selectedIndex = 0
        }
        .onKeyPress(.escape) {
            viewModel.dismiss?()
            return .handled
        }
        .onKeyPress(.return) {
            guard selectedIndex < viewModel.filteredItems.count else { return .handled }
            viewModel.selectItem(viewModel.filteredItems[selectedIndex])
            return .handled
        }
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 {
                selectedIndex -= 1
                keyboardScrollTarget = selectedIndex
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if selectedIndex < viewModel.filteredItems.count - 1 {
                selectedIndex += 1
                keyboardScrollTarget = selectedIndex
            }
            return .handled
        }
    }

    // MARK: - Type Filter

    private var typeFilterBar: some View {
        HStack(spacing: 2) {
            ForEach(viewModel.availableTypes, id: \.self) { type in
                filterButton(
                    icon: type?.sfSymbol ?? "tray",
                    label: type.flatMap(typeName) ?? Strings.filterAll,
                    isSelected: viewModel.selectedType == type,
                    action: {
                        viewModel.selectedType = type
                        selectedIndex = 0
                    }
                )
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.05))
        }
    }

    private func filterButton(icon: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .primary : .secondary.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary.opacity(0.1))
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private func typeName(for type: PasteboardItem.ContentType) -> String {
        switch type {
        case .text: return Strings.filterText
        case .link: return Strings.filterLink
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 16) {
            Label(Strings.footerCopyHint, systemImage: "return")
            Label(Strings.footerCloseHint, systemImage: "escape")
        }
        .font(.system(size: 10))
        .foregroundColor(.secondary.opacity(0.5))
        .padding(.horizontal, Constants.panelPaddingH)
        .padding(.vertical, 6)
    }
}

