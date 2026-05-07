import AppKit
import Sparkle

final class UpdaterController: NSObject {
    private let updater: SPUStandardUpdaterController
    private let updaterDelegate: UpdaterDelegate

    override init() {
        let delegate = UpdaterDelegate()
        self.updaterDelegate = delegate
        self.updater = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: delegate,
            userDriverDelegate: nil
        )
        super.init()
    }

    func checkForUpdates() {
        updater.checkForUpdates(nil)
    }
}

private final class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        ["release"]
    }

    func feedURLString(for updater: SPUUpdater) -> String? {
        "https://github.com/[owner]/CopyKeep/releases/latest/download/appcast.xml"
    }
}
