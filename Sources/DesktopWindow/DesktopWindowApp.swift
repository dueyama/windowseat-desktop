import AppKit
import DesktopWindowCore

@MainActor
final class DesktopWindowApp: NSObject, NSApplicationDelegate {
    private var windowManager: BackgroundWindowManager?
    private var statusMenuController: StatusMenuController?
    private var didStart = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        startIfNeeded()
    }

    func startIfNeeded() {
        guard !didStart else {
            return
        }

        didStart = true

        let configuration = loadConfiguration()
        Diagnostics.configure(path: configuration.diagnosticsLogPath)
        Diagnostics.log("start debugWindow=\(configuration.debugWindow) source=\(configuration.source?.youtubeVideoID.rawValue ?? "nil")")
        RunningInstanceGuard.acquire()
        NSApplication.shared.setActivationPolicy(configuration.debugWindow ? .regular : .accessory)

        let manager = BackgroundWindowManager(configuration: configuration)
        let statusController = StatusMenuController(
            configuration: configuration,
            sourceProvider: { [weak manager] in manager?.source },
            onReload: { [weak manager] in manager?.reload() },
            onSetMuted: { [weak manager] muted in manager?.setMuted(muted) },
            bookmarksProvider: { [weak manager] in manager?.bookmarks ?? [] },
            onBookmarkCurrent: { [weak manager] in manager?.bookmarkCurrentSource() },
            onApplyBookmark: { [weak manager] source in manager?.applyBookmark(source) }
        )
        manager.onSourceChanged = { [weak statusController] in
            statusController?.refreshMenu()
        }

        windowManager = manager
        statusMenuController = statusController

        manager.show()
        Diagnostics.log("manager.show completed")

        if configuration.debugWindow {
            AppActivation.bringForward()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        RunningInstanceGuard.release()
        windowManager?.close()
    }

    private func loadConfiguration() -> AppConfiguration {
        do {
            return try AppConfigurationParser.parse(arguments: CommandLine.arguments)
        } catch {
            return AppConfiguration(
                debugWindow: true,
                statusMessage: error.localizedDescription
            )
        }
    }
}
