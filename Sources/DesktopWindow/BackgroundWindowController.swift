import AppKit
import DesktopWindowCore
import WebKit

@MainActor
final class BackgroundWindowController: NSWindowController {
    private let webView: WKWebView
    private let isDebugWindow: Bool

    init(screen: NSScreen, configuration: AppConfiguration) {
        isDebugWindow = configuration.debugWindow

        let window = DesktopBackgroundWindow(
            contentRect: screen.frame,
            styleMask: configuration.debugWindow ? [.titled, .closable, .resizable] : [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = false

        let contentView = NSView(frame: screen.frame)
        contentView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        window.contentView = contentView
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = false
        window.title = "WindowSeat"

        if configuration.debugWindow {
            window.level = .floating
            window.isMovableByWindowBackground = true
            window.collectionBehavior = [.moveToActiveSpace]

            let frame = Self.debugFrame(on: screen)
            window.setFrame(frame, display: false)
        } else {
            window.level = Self.desktopLevel
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .stationary,
                .ignoresCycle,
                .fullScreenAuxiliary
            ]
            window.ignoresMouseEvents = true
        }

        super.init(window: window)
        Diagnostics.log("window initialized debug=\(configuration.debugWindow) frame=\(window.frame) level=\(window.level.rawValue)")
        reload(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)

        guard let window else {
            return
        }

        if isDebugWindow {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            AppActivation.bringForward()
        } else {
            window.orderFrontRegardless()
        }

        Diagnostics.log("showWindow debug=\(isDebugWindow) visible=\(window.isVisible) frame=\(window.frame) level=\(window.level.rawValue)")
    }

    func reload(configuration: AppConfiguration) {
        let html: String

        if let source = configuration.source {
            html = YouTubeEmbedPage.html(source: source)
        } else {
            html = YouTubeEmbedPage.placeholder(
                message: configuration.statusMessage ?? "No scenic source configured."
            )
        }

        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    func setMuted(_ muted: Bool) {
        let value = muted ? "true" : "false"
        webView.evaluateJavaScript("window.desktopWindowSetMuted(\(value));")
    }

    private static var desktopLevel: NSWindow.Level {
        NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
    }

    private static func debugFrame(on screen: NSScreen) -> NSRect {
        let visibleFrame = screen.visibleFrame
        let width = min(960, visibleFrame.width * 0.82)
        let height = width * 9 / 16

        return NSRect(
            x: visibleFrame.midX - width / 2,
            y: visibleFrame.midY - height / 2,
            width: width,
            height: height
        )
    }
}
