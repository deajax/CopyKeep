import AppKit
import ApplicationServices

enum AccessibilityPermission {
    static func isTrusted(prompt: Bool = false) -> Bool {
        if AXIsProcessTrusted() {
            return true
        }
        guard prompt else { return false }
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func requestPromptIfNeeded() {
        _ = isTrusted(prompt: true)
    }

    static func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    static var executablePath: String {
        Bundle.main.executablePath ?? ProcessInfo.processInfo.arguments.first ?? "-"
    }

    static var bundlePath: String {
        Bundle.main.bundlePath
    }
}
