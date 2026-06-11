import XCTest
@testable import DesktopWindowCore

final class YouTubeVideoIDTests: XCTestCase {
    func testAcceptsStandardVideoID() {
        XCTAssertEqual(YouTubeVideoID("TESTVIDEO01")?.rawValue, "TESTVIDEO01")
    }

    func testRejectsWrongLengthVideoID() {
        XCTAssertNil(YouTubeVideoID("short"))
        XCTAssertNil(YouTubeVideoID("TESTVIDEO01-extra"))
    }

    func testRejectsUnsafeCharacters() {
        XCTAssertNil(YouTubeVideoID("<script>bad"))
        XCTAssertNil(YouTubeVideoID("TESTVIDEO+1"))
    }
}
