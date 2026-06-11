import XCTest
@testable import DesktopWindowCore

final class SourceBookmarkStoreTests: XCTestCase {
    func testLoadReturnsEmptyListForMissingFile() throws {
        let url = temporaryDirectory().appendingPathComponent("sources.json")

        XCTAssertEqual(try SourceBookmarkStore.load(from: url), [])
    }

    func testSaveAndLoadBookmarks() throws {
        let url = temporaryDirectory().appendingPathComponent("Config/sources.json")
        let source = ScenicSource(
            title: "Maldives",
            youtubeVideoID: try XCTUnwrap(YouTubeVideoID("h9ba5qkpNA4")),
            sourceKind: .live
        )

        try SourceBookmarkStore.save([source], to: url)

        let loadedSources = try SourceBookmarkStore.load(from: url)
        XCTAssertEqual(loadedSources.count, 1)
        XCTAssertEqual(loadedSources.first?.title, "Maldives")
        XCTAssertEqual(loadedSources.first?.youtubeVideoID.rawValue, "h9ba5qkpNA4")
    }

    func testUpsertingMovesExistingBookmarkToFrontWithoutDuplication() throws {
        let first = ScenicSource(
            title: "Koh Samui",
            youtubeVideoID: try XCTUnwrap(YouTubeVideoID("Fw9hgttWzIg"))
        )
        let second = ScenicSource(
            title: "Maldives",
            youtubeVideoID: try XCTUnwrap(YouTubeVideoID("h9ba5qkpNA4"))
        )
        let updatedFirst = ScenicSource(
            title: "Koh Samui Beach",
            youtubeVideoID: try XCTUnwrap(YouTubeVideoID("Fw9hgttWzIg"))
        )

        let bookmarks = SourceBookmarkStore.upserting(updatedFirst, into: [first, second])

        XCTAssertEqual(bookmarks.map(\.youtubeVideoID.rawValue), ["Fw9hgttWzIg", "h9ba5qkpNA4"])
        XCTAssertEqual(bookmarks.first?.title, "Koh Samui Beach")
    }

    private func temporaryDirectory() -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
