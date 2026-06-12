import XCTest
@testable import DesktopWindowCore

final class YouTubeEmbedPageTests: XCTestCase {
    func testEmbedUsesPrivacyEnhancedYouTubeHost() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let html = YouTubeEmbedPage.html(videoID: videoID, fillMode: .fill)

        XCTAssertTrue(html.contains("https://www.youtube.com/iframe_api"))
        XCTAssertTrue(html.contains("videoId: 'TESTVIDEO01'"))
        XCTAssertTrue(html.contains("autoplay: 1"))
        XCTAssertTrue(html.contains("const initialMuted = true"))
        XCTAssertTrue(html.contains("const preferredQuality = 'highres'"))
        XCTAssertTrue(html.contains("const shouldSyncToLiveEdge = false"))
        XCTAssertTrue(html.contains("vq: preferredQuality"))
        XCTAssertTrue(html.contains("setPlaybackQuality(preferredQuality)"))
        XCTAssertTrue(html.contains("onError"))
        XCTAssertTrue(html.contains("showPlaybackError"))
        XCTAssertTrue(html.contains("playback-failed"))
        XCTAssertFalse(html.contains("埋め込み再生できません"))
    }

    func testSourceCanRequestUnmutedPlayback() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let source = ScenicSource(title: "Sound Test", youtubeVideoID: videoID, muted: false)
        let html = YouTubeEmbedPage.html(source: source)

        XCTAssertTrue(html.contains("const initialMuted = false"))
        XCTAssertTrue(html.contains("window.desktopWindowSetMuted"))
    }

    func testLiveSourceSyncsToLiveEdgeOnStartup() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let source = ScenicSource(
            title: "Live Test",
            youtubeVideoID: videoID,
            sourceKind: .live
        )
        let html = YouTubeEmbedPage.html(source: source)

        XCTAssertTrue(html.contains("const shouldSyncToLiveEdge = true"))
        XCTAssertTrue(html.contains("function syncToLiveEdge(target)"))
        XCTAssertTrue(html.contains("Number(target.getDuration())"))
        XCTAssertTrue(html.contains("target.seekTo(liveEdgeSeconds, true)"))
        XCTAssertTrue(html.contains("scheduleLiveEdgeSync(event.target)"))
    }

    func testRecordingSourceDoesNotSyncToLiveEdge() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let source = ScenicSource(
            title: "Recording Test",
            youtubeVideoID: videoID,
            sourceKind: .recording
        )
        let html = YouTubeEmbedPage.html(source: source)

        XCTAssertTrue(html.contains("const shouldSyncToLiveEdge = false"))
    }

    func testPlaceholderEscapesHTML() {
        let html = YouTubeEmbedPage.placeholder(message: "<b>bad</b>")

        XCTAssertTrue(html.contains("&lt;b&gt;bad&lt;/b&gt;"))
        XCTAssertFalse(html.contains("<b>bad</b>"))
    }

    func testSourceOverlayEscapesAgentText() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let source = ScenicSource(
            title: "Overlay Test",
            youtubeVideoID: videoID,
            showOverlay: true,
            agentNote: AgentNote(headline: "<today>", body: "Work & breathe"),
            quote: ScenicQuote(text: "\"Look far\"", attribution: "Agent")
        )

        let html = YouTubeEmbedPage.html(source: source)

        XCTAssertTrue(html.contains("agent-note"))
        XCTAssertTrue(html.contains("&lt;today&gt;"))
        XCTAssertTrue(html.contains("Work &amp; breathe"))
        XCTAssertTrue(html.contains("&quot;Look far&quot;"))
    }

    func testSourceOverlayIsHiddenByDefault() throws {
        let videoID = try XCTUnwrap(YouTubeVideoID("TESTVIDEO01"))
        let source = ScenicSource(
            title: "Overlay Test",
            youtubeVideoID: videoID,
            agentNote: AgentNote(headline: "Today", body: "Hidden by default")
        )

        let html = YouTubeEmbedPage.html(source: source)

        XCTAssertFalse(html.contains("<section class=\"agent-note\">"))
        XCTAssertFalse(html.contains("Hidden by default"))
    }
}
