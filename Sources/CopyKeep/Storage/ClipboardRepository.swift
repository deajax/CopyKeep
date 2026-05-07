import Foundation
import GRDB

final class ClipboardRepository {
    private let db: DatabaseManager
    private let maxHistory: Int

    init(db: DatabaseManager, maxHistory: Int = Constants.defaultMaxHistory) {
        self.db = db
        self.maxHistory = maxHistory
    }

    func insertOrUpdate(content: String, contentType: PasteboardItem.ContentType, appName: String?) throws {
        let hash = content.sha256

        try db.write { database in
            let existing = try DatabaseManager.StoredItem
                .filter(Column("content_hash") == hash)
                .fetchOne(database)

            if var existing {
                existing.updated_at = Date()
                try existing.update(database)
            } else {
                let item = DatabaseManager.StoredItem(
                    content: content,
                    content_hash: hash,
                    content_type: contentType.rawValue,
                    app_name: appName,
                    created_at: Date(),
                    updated_at: Date(),
                    is_pinned: false
                )
                try item.insert(database)

                let count = try DatabaseManager.StoredItem.fetchCount(database)
                if count > maxHistory {
                    try database.execute(sql: """
                        DELETE FROM clipboard_items
                        WHERE id IN (
                            SELECT id FROM clipboard_items
                            WHERE is_pinned = 0
                            ORDER BY updated_at ASC
                            LIMIT ?
                        )
                    """, arguments: [count - maxHistory])
                }
            }
        }
    }

    func fetchRecent(limit: Int = Constants.maxVisibleItems) throws -> [PasteboardItem] {
        try db.read { database in
            let rows = try DatabaseManager.StoredItem
                .order(Column("updated_at").desc)
                .limit(limit)
                .fetchAll(database)
            return rows.map { mapToPasteboardItem($0) }
        }
    }

    func search(query: String, type: PasteboardItem.ContentType?, limit: Int = Constants.maxVisibleItems) throws -> [PasteboardItem] {
        try db.read { database in
            var sql = """
                SELECT ci.* FROM clipboard_items ci
                INNER JOIN clipboard_items_fts fts ON ci.id = fts.rowid
                WHERE clipboard_items_fts MATCH ?
            """
            var args: [Any] = [query]

            if let type {
                sql += " AND ci.content_type = ?"
                args.append(type.rawValue)
            }

            sql += " ORDER BY ci.updated_at DESC LIMIT ?"
            args.append(limit)

            let rows = try DatabaseManager.StoredItem.fetchAll(database, sql: sql, arguments: StatementArguments(args)!)
            return rows.map { mapToPasteboardItem($0) }
        }
    }

    func fetchByType(_ type: PasteboardItem.ContentType, limit: Int = Constants.maxVisibleItems) throws -> [PasteboardItem] {
        try db.read { database in
            let rows = try DatabaseManager.StoredItem
                .filter(Column("content_type") == type.rawValue)
                .order(Column("updated_at").desc)
                .limit(limit)
                .fetchAll(database)
            return rows.map { mapToPasteboardItem($0) }
        }
    }

    func deleteItem(id: Int64) throws {
        try db.write { database in
            try DatabaseManager.StoredItem.deleteOne(database, key: id)
        }
    }

    func clearAll() throws {
        try db.write { database in
            try database.execute(sql: "DELETE FROM clipboard_items")
            try database.execute(sql: "INSERT INTO clipboard_items_fts(clipboard_items_fts) VALUES('rebuild')")
        }
    }

    func updateMaxHistory(_ newMax: Int) {
        guard newMax >= Constants.minHistory, newMax <= Constants.maxHistory else { return }
        // Force re-evaluating maxHistory — stored as a mutable property
    }

    private func mapToPasteboardItem(_ stored: DatabaseManager.StoredItem) -> PasteboardItem {
        PasteboardItem(
            id: stored.id,
            content: stored.content,
            contentType: PasteboardItem.ContentType(rawValue: stored.content_type) ?? .text,
            appName: stored.app_name,
            createdAt: stored.created_at,
            updatedAt: stored.updated_at,
            isPinned: stored.is_pinned
        )
    }
}

private extension String {
    var sha256: String {
        let data = Data(utf8)
        let hash = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> [UInt8] in
            var bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &bytes)
            return bytes
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

import CommonCrypto
