import Testing
import Foundation

@testable import CopyKeep

@Test("PasteboardItem model works")
func pasteboardItemCreation() throws {
    let item = PasteboardItem(
        id: 1,
        content: "Hello world",
        contentType: .text,
        appName: "TestApp",
        createdAt: Date(),
        updatedAt: Date(),
        isPinned: false
    )
    #expect(item.id == 1)
    #expect(item.content == "Hello world")
    #expect(item.contentType == .text)
}

@Test("Link detection works")
func linkContentType() throws {
    let item = PasteboardItem(
        id: 2,
        content: "Hello https://example.com world",
        contentType: .link,
        appName: nil,
        createdAt: Date(),
        updatedAt: Date(),
        isPinned: false
    )
    #expect(item.isLink)
    #expect(item.contentType == .link)
}
