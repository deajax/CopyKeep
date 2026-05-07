import Foundation
import Combine

final class ClipboardViewModel: ObservableObject {
    @Published var items: [PasteboardItem] = []
    @Published var searchText: String = ""
    @Published var selectedType: PasteboardItem.ContentType? = nil

    var onPasteRequested: ((String) -> Void)?
    var dismiss: (() -> Void)?

    private let repository: ClipboardRepository

    let availableTypes: [PasteboardItem.ContentType?] = [nil, .text, .link]

    var filteredItems: [PasteboardItem] {
        let source = items

        if searchText.isEmpty, selectedType == nil {
            return source
        }

        return source.filter { item in
            let matchesType = selectedType == nil || item.contentType == selectedType
            let matchesSearch = searchText.isEmpty
                || item.content.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }

    init(repository: ClipboardRepository) {
        self.repository = repository
        reload()
    }

    func reload() {
        do {
            items = try repository.fetchRecent(limit: Constants.maxHistory)
        } catch {
            print("[CopyKeep] Failed to reload items: \(error)")
        }
    }

    func selectItem(_ item: PasteboardItem) {
        onPasteRequested?(item.content)
    }

    func clearHistory() {
        do {
            try repository.clearAll()
            items = []
        } catch {
            print("[CopyKeep] Failed to clear history: \(error)")
        }
    }

    func deleteItem(_ item: PasteboardItem) {
        guard let id = item.id else { return }
        do {
            try repository.deleteItem(id: id)
            reload()
        } catch {
            print("[CopyKeep] Failed to delete item: \(error)")
        }
    }
}
