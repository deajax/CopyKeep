import AppKit

extension NSPasteboard {
    /// Sets the given text as the sole content of the pasteboard.
    @discardableResult
    func copyText(_ text: String) -> Bool {
        clearContents()
        return setString(text, forType: .string)
    }

    /// Stores the current pasteboard content and returns a restoration block.
    /// Call the returned closure to restore the saved content.
    func saveAndRestore() -> (() -> Void)? {
        guard let items = pasteboardItems?.compactMap({ $0 }) else { return nil }

        return { [weak self] in
            self?.clearContents()
            self?.writeObjects(items)
        }
    }
}
