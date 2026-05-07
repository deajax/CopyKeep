import AppKit
import CoreGraphics
import Carbon.HIToolbox

enum PasteHelper {
    enum FailureReason {
        case accessibilityPermissionDenied
        case secureInputEnabled
        case eventSourceUnavailable
        case pasteboardWriteFailed
    }

    enum Mode: String {
        case clipboardPaste = "clipboardPaste"
        case smartInsert = "smartInsert"
    }

    private static let pasteTap: CGEventTapLocation = .cghidEventTap

    private static var currentMode: Mode {
        let raw = UserDefaults.standard.string(forKey: "pasteMode") ?? "clipboardPaste"
        return Mode(rawValue: raw) ?? .clipboardPaste
    }

    /// Insert text at cursor. `targetPID` is the process ID of the frontmost app
    /// captured BEFORE the CopyKeep panel opened.
    static func insertTextAtCursor(_ text: String, targetPID: pid_t, onFailure: ((FailureReason) -> Void)? = nil) {
        guard !text.isEmpty else { return }

        let trusted = AccessibilityPermission.isTrusted()
        NSLog("[CopyKeep] Accessibility trusted: \(trusted), app path: \(AccessibilityPermission.bundlePath)")
        guard trusted else {
            onFailure?(.accessibilityPermissionDenied)
            return
        }

        if IsSecureEventInputEnabled() {
            NSLog("[CopyKeep] Secure Event Input is enabled, cannot insert text")
            onFailure?(.secureInputEnabled)
            return
        }

        activateTargetAppIfNeeded(targetPID) {
            switch currentMode {
            case .clipboardPaste:
                insertViaClipboard(text, onFailure: onFailure)
            case .smartInsert:
                insertViaCGEvent(text, onFailure: onFailure)
            }
        }
    }

    // MARK: - 剪贴板粘贴

    private static func insertViaClipboard(_ text: String, onFailure: ((FailureReason) -> Void)? = nil) {
        let pb = NSPasteboard.general
        let restore = pb.saveAndRestore()

        guard pb.copyText(text) else {
            NSLog("[CopyKeep] Failed to write text to pasteboard")
            onFailure?(.pasteboardWriteFailed)
            return
        }

        let pastedChangeCount = pb.changeCount
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            if !simulateCmdV() {
                onFailure?(.eventSourceUnavailable)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            // Avoid overriding user clipboard if it changed after our temporary write.
            guard pb.changeCount == pastedChangeCount else { return }
            restore?()
        }
    }

    private static func simulateCmdV() -> Bool {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return false }

        guard
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        else {
            return false
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: pasteTap)
        keyUp.post(tap: pasteTap)
        return true
    }

    // MARK: - 智能插入

    private static func insertViaCGEvent(_ text: String, onFailure: ((FailureReason) -> Void)? = nil) {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            onFailure?(.eventSourceUnavailable)
            return
        }

        let chars = Array(text.utf16)
        guard !chars.isEmpty else { return }

        guard
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        else {
            onFailure?(.eventSourceUnavailable)
            return
        }

        keyDown.keyboardSetUnicodeString(stringLength: chars.count, unicodeString: chars)
        keyDown.post(tap: pasteTap)

        keyUp.keyboardSetUnicodeString(stringLength: chars.count, unicodeString: chars)
        keyUp.post(tap: pasteTap)
    }

    private static func activateTargetAppIfNeeded(_ capturedTargetPID: pid_t, completion: @escaping () -> Void) {
        let selfPID = ProcessInfo.processInfo.processIdentifier
        let frontmostPID = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0

        // If user has already switched back to another app, use current foreground app.
        if frontmostPID != 0, frontmostPID != selfPID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03, execute: completion)
            return
        }

        guard
            capturedTargetPID != 0,
            capturedTargetPID != selfPID,
            let target = NSRunningApplication(processIdentifier: capturedTargetPID)
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03, execute: completion)
            return
        }

        _ = target.activate()

        waitForActivation(of: target, attempts: 10) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: completion)
        }
    }

    private static func waitForActivation(of app: NSRunningApplication, attempts: Int, completion: @escaping () -> Void) {
        if app.isActive || attempts <= 0 {
            completion()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            waitForActivation(of: app, attempts: attempts - 1, completion: completion)
        }
    }
}
