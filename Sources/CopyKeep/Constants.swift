import AppKit

enum Constants {
    static let appName = "CopyKeep"
    static let defaultMaxHistory: Int = 200
    static let minHistory: Int = 3
    static let maxHistory: Int = 999
    static let pasteboardPollInterval: TimeInterval = 0.5
    static let panelWidth: CGFloat = 380
    static let maxVisibleItems: Int = 12
    static let bundleID = "com.copykeep.app"

    // Spacing (8pt macOS grid)
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // Radius
    static let radiusSM: CGFloat = 6
    static let radiusMD: CGFloat = 10
    static let radiusLG: CGFloat = 14

    // Row
    static let rowHeight: CGFloat = 52
    static let rowIconSize: CGFloat = 18

    // Panel
    static let panelPaddingH: CGFloat = 10
    static let panelPaddingV: CGFloat = 8

    static let appSupportDir: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        return ((paths.first as NSString?)?.appendingPathComponent(appName))
            ?? ("~/Library/Application Support/CopyKeep" as NSString).expandingTildeInPath
    }()
}
