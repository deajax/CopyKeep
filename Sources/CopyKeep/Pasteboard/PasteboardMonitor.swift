import AppKit
import Combine

final class PasteboardMonitor {
    private let repository: ClipboardRepository
    private let viewModel: ClipboardViewModel
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private let queue = DispatchQueue(label: "com.copykeep.pasteboard", qos: .background)

    init(repository: ClipboardRepository, viewModel: ClipboardViewModel) {
        self.repository = repository
        self.viewModel = viewModel
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        let t = Timer(timeInterval: Constants.pasteboardPollInterval, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        let current = pb.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current
        // Read pasteboard data on main thread (NSPasteboard is not thread-safe)
        guard let item = pb.pasteboardItems?.first,
              let contentType = extractContent(from: item) else { return }

        let detectedType: PasteboardItem.ContentType
        if contentType.type == .text, isLink(contentType.text) {
            detectedType = .link
        } else {
            detectedType = contentType.type
        }

        let appName = NSWorkspace.shared.frontmostApplication?.localizedName

        queue.async { [weak self] in
            guard let self else { return }

            do {
                try self.repository.insertOrUpdate(
                    content: contentType.text,
                    contentType: detectedType,
                    appName: appName
                )
            } catch {}

            DispatchQueue.main.async {
                self.viewModel.reload()
            }
        }
    }

    /// Extract content from pasteboard item on the main thread.
    private func extractContent(from item: NSPasteboardItem) -> (type: PasteboardItem.ContentType, text: String)? {
        // Only text content is supported; images and files are ignored.
        guard let text = item.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return (.text, text)
    }

    private func isLink(_ text: String) -> Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = detector.matches(in: text, range: range)
        return !matches.isEmpty
    }
}

