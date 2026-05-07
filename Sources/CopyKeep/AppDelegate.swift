import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()
    private(set) var clipboardVM: ClipboardViewModel?
    private var menuBarManager: MenuBarManager?
    private var pasteboardMonitor: PasteboardMonitor?
    private var databaseManager: DatabaseManager?
    private var clipboardRepository: ClipboardRepository?
    private var hotkeyManager: HotkeyManager?
    private var clipboardPanel: ClipboardPanel?
    private var updaterController: UpdaterController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        do {
            try FileManager.default.createDirectory(atPath: Constants.appSupportDir, withIntermediateDirectories: true)
        } catch {
            NSLog("[CopyKeep] Failed to create app support directory: %@", error.localizedDescription)
        }

        let dbManager = DatabaseManager()
        self.databaseManager = dbManager
        let repository = ClipboardRepository(db: dbManager)
        self.clipboardRepository = repository

        let vm = ClipboardViewModel(repository: repository)
        self.clipboardVM = vm

        let panel = ClipboardPanel(viewModel: vm)
        self.clipboardPanel = panel

        let menuBar = MenuBarManager(panel: panel, viewModel: vm)
        self.menuBarManager = menuBar

        let monitor = PasteboardMonitor(repository: repository, viewModel: vm)
        self.pasteboardMonitor = monitor
        monitor.start()

        let hotkey = HotkeyManager(panel: panel)
        self.hotkeyManager = hotkey
        hotkey.register()

        let updater = UpdaterController()
        self.updaterController = updater

        vm.onPasteRequested = { [weak panel] (content: String) in
            NSPasteboard.general.copyText(content)
            panel?.close()
        }

        vm.dismiss = { [weak panel] in
            panel?.close()
        }
    }

}
