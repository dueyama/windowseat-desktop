import XCTest
@testable import DesktopWindowCore

final class AppConfigurationParserTests: XCTestCase {
    func testParsesVideoIDArgument() throws {
        let configuration = try AppConfigurationParser.parse(
            arguments: ["DesktopWindow", "--video-id", "TESTVIDEO01", "--fill-mode", "fit"],
            environment: [:]
        )

        XCTAssertEqual(configuration.source?.youtubeVideoID.rawValue, "TESTVIDEO01")
        XCTAssertEqual(configuration.source?.fillMode, .fit)
    }

    func testParsesEnvironmentVideoID() throws {
        let configuration = try AppConfigurationParser.parse(
            arguments: ["DesktopWindow"],
            environment: ["DESKTOP_WINDOW_VIDEO_ID": "TESTVIDEO01"]
        )

        XCTAssertEqual(configuration.source?.youtubeVideoID.rawValue, "TESTVIDEO01")
    }

    func testRejectsInvalidVideoID() {
        XCTAssertThrowsError(
            try AppConfigurationParser.parse(
                arguments: ["DesktopWindow", "--video-id", "not-valid"],
                environment: [:]
            )
        ) { error in
            XCTAssertEqual(error as? ConfigurationError, .invalidVideoID("not-valid"))
        }
    }

    func testReturnsPlaceholderConfigurationWithoutSource() throws {
        let configuration = try AppConfigurationParser.parse(arguments: ["DesktopWindow"], environment: [:])

        XCTAssertNil(configuration.source)
        XCTAssertNotNil(configuration.statusMessage)
    }

    func testParsesSingleCurrentSourceFile() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)

        let sourceURL = temporaryDirectory.appendingPathComponent("current-source.json")
        try """
        {
          "title": "Calm Window",
          "youtubeVideoID": "TESTVIDEO01",
          "fillMode": "fill",
          "selectedBy": "Codex",
          "agentNote": {
            "headline": "今日は遠景から始めましょう",
            "body": "静かな景色を作業の背景にします。"
          },
          "quote": {
            "text": "近くの仕事ほど、遠くを見る時間が効く。"
          }
        }
        """.write(to: sourceURL, atomically: true, encoding: .utf8)

        let configuration = try AppConfigurationParser.parse(
            arguments: ["DesktopWindow", "--source-file", sourceURL.path],
            environment: [:]
        )

        XCTAssertEqual(configuration.source?.title, "Calm Window")
        XCTAssertEqual(configuration.source?.muted, true)
        XCTAssertEqual(configuration.source?.showOverlay, false)
        XCTAssertNil(configuration.source?.sourceKind)
        XCTAssertEqual(configuration.source?.preferredQuality, .highres)
        XCTAssertEqual(configuration.source?.agentNote?.headline, "今日は遠景から始めましょう")
        XCTAssertEqual(configuration.source?.quote?.text, "近くの仕事ほど、遠くを見る時間が効く。")
    }
}
