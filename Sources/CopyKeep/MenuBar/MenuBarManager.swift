import AppKit
import SwiftUI

final class MenuBarManager: NSObject {
    private let statusItem: NSStatusItem
    private let panel: ClipboardPanel
    private let viewModel: ClipboardViewModel

    init(panel: ClipboardPanel, viewModel: ClipboardViewModel) {
        self.panel = panel
        self.viewModel = viewModel

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            let icon = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "CopyKeep 剪贴板管理")
            icon?.isTemplate = true
            button.image = icon
            button.action = #selector(togglePanel)
            button.target = self
        }

        let menu = NSMenu()
        let showItem = NSMenuItem(title: Strings.menuShowCopyKeep, action: #selector(showPanel), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)
        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: Strings.menuSettings, action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let clearItem = NSMenuItem(title: Strings.menuClearHistory, action: #selector(clearHistory), keyEquivalent: "")
        clearItem.target = self
        menu.addItem(clearItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: Strings.menuQuit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func togglePanel() {
        if panel.isVisible {
            panel.close()
        } else {
            panel.showAtCursor()
        }
    }

    @objc private func showPanel() {
        panel.showAtCursor()
    }

    private var settingsWindow: NSWindow?

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 300),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = Strings.settingsTitle
            window.appearance = NSAppearance(named: .aqua)
            window.contentView = NSHostingView(rootView: SettingsView())
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func clearHistory() {
        viewModel.clearHistory()
    }
}
