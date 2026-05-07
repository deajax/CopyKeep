import AppKit
import KeyboardShortcuts

final class HotkeyManager {
    private let panel: ClipboardPanel

    init(panel: ClipboardPanel) {
        self.panel = panel
    }

    func register() {
        KeyboardShortcuts.onKeyUp(for: .toggleClipboardPanel) { [weak self] in
            guard let self else { return }
            self.panel.toggle()
        }
    }
}

extension KeyboardShortcuts.Name {
    static let toggleClipboardPanel = Self("toggleClipboardPanel", default: .init(.v, modifiers: [.command, .shift]))
}
