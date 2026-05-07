import Foundation
import GRDB

final class DatabaseManager {
    private let dbQueue: DatabaseQueue

    init() {
        let dbPath = NSString(string: Constants.appSupportDir).appendingPathComponent("clipboard_history.sqlite")
        do {
            dbQueue = try DatabaseQueue(path: dbPath)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("[CopyKeep] Database initialization failed: \(error)")
        }
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1_schema") { db in
            try db.create(table: "clipboard_items", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content", .text).notNull()
                t.column("content_hash", .text).notNull()
                t.column("content_type", .text).notNull().defaults(to: "text")
                t.column("app_name", .text)
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
                t.column("is_pinned", .boolean).notNull().defaults(to: false)
            })

            try db.create(index: "idx_content_hash", on: "clipboard_items", columns: ["content_hash"])
            try db.create(index: "idx_updated_at", on: "clipboard_items", columns: ["updated_at"])
            try db.create(index: "idx_content_type", on: "clipboard_items", columns: ["content_type"])

            try db.execute(sql: """
                CREATE VIRTUAL TABLE IF NOT EXISTS clipboard_items_fts
                USING fts5(content, content=clipboard_items, content_rowid=id)
            """)
        }
        return migrator
    }

    func read<T>(_ block: (GRDB.Database) throws -> T) throws -> T {
        try dbQueue.read(block)
    }

    func write(_ block: (GRDB.Database) throws -> Void) throws {
        try dbQueue.write(block)
    }
}

extension DatabaseManager {
    struct StoredItem: Codable, FetchableRecord, PersistableRecord {
        static let databaseTableName = "clipboard_items"

        var id: Int64?
        var content: String
        var content_hash: String
        var content_type: String
        var app_name: String?
        var created_at: Date
        var updated_at: Date
        var is_pinned: Bool
    }
}
