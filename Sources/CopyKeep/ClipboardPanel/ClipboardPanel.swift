import AppKit
import SwiftUI

final class ClipboardPanel: NSPanel {
    private let viewModel: ClipboardViewModel

    init(viewModel: ClipboardViewModel) {
        self.viewModel = viewModel

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: Constants.panelWidth, height: 500),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        configurePanel()
        setupContentView()
    }

    private func configurePanel() {
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        isOpaque = false
        backgroundColor = NSColor.clear
        hasShadow = true
        isMovable = false
        ignoresMouseEvents = false
        isRestorable = false
        delegate = self
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    private func setupContentView() {
        let hostingView = NSHostingView(
            rootView: PanelContent(viewModel: viewModel)
        )
        hostingView.frame = NSRect(x: 0, y: 0, width: Constants.panelWidth, height: 500)
        contentView = hostingView
    }

    func toggle() {
        if isVisible {
            close()
        } else {
            showAtCursor()
        }
    }

    func showAtCursor() {
        let mouseLocation = NSEvent.mouseLocation
        let panelHeight: CGFloat = calculatePanelHeight()

        let x = min(mouseLocation.x + 20, NSScreen.main?.visibleFrame.maxX ?? 0 - Constants.panelWidth - 20)
        let y = max(mouseLocation.y - panelHeight - 30, (NSScreen.main?.visibleFrame.minY ?? 0) + 20)

        setFrame(NSRect(x: x, y: y, width: Constants.panelWidth, height: panelHeight), display: true)

        viewModel.reload()
        viewModel.searchText = ""
        makeKeyAndOrderFront(nil)
    }

    private func calculatePanelHeight() -> CGFloat {
        let itemCount = min(viewModel.filteredItems.count, Constants.maxVisibleItems)
        guard itemCount > 0 else { return 140 }
        return CGFloat(itemCount) * 28 + 85
    }

}

extension ClipboardPanel: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        close()
    }
}
