import AppKit
import SwiftUI

struct PasteboardItem: Identifiable, Hashable {
    let id: Int64?
    let content: String
    let contentType: ContentType
    let appName: String?
    let createdAt: Date
    let updatedAt: Date
    let isPinned: Bool

    enum ContentType: String, CaseIterable, Codable {
        case text
        case link

        var displayName: String {
            switch self {
            case .text: return "文本"
            case .link: return "链接"
            }
        }

        var sfSymbol: String {
            switch self {
            case .text: return "doc.text"
            case .link: return "link"
            }
        }

        var color: Color {
            switch self {
            case .text: return .blue
            case .link: return .purple
            }
        }
    }

    var isLink: Bool {
        contentType == .link
    }

    var truncatedContent: String {
        content.prefix(150).trimmingCharacters(in: .whitespacesAndNewlines)
            + (content.count > 150 ? "..." : "")
    }

    var formattedTime: String {
        let cal = Calendar.current
        if cal.isDateInToday(updatedAt) {
            return Self.timeFormatter.string(from: updatedAt)
        } else if cal.isDateInYesterday(updatedAt) {
            return "\(Strings.yesterday) \(Self.timeFormatter.string(from: updatedAt))"
        } else {
            return Self.dateFormatter.string(from: updatedAt)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh-Hans")
        f.dateFormat = "MM月dd日 HH:mm"
        return f
    }()
}
