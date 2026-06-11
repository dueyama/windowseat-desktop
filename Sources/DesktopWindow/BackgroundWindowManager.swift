import AppKit
import DesktopWindowCore

@MainActor
final class BackgroundWindowManager {
    private var configuration: AppConfiguration
    private var controllers: [BackgroundWindowController] = []
    private var screenObserver: NSObjectProtocol?
    private var sourceFilePollTimer: Timer?
    private var lastSourceFileModificationDate: Date?
    var onSourceChanged: (() -> Void)?

    var source: ScenicSource? {
        configuration.source
    }

    init(configuration: AppConfiguration) {
        self.configuration = configuration
    }

    func show() {
        rebuildWindows()
        startSourceFilePollingIfNeeded()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.rebuildWindows()
            }
        }
    }

    func reload() {
        if configuration.sourceFilePath != nil {
            reloadSourceFile(force: true)
        } else {
            controllers.forEach { $0.reload(configuration: configuration) }
        }
    }

    func setMuted(_ muted: Bool) {
        guard var source = configuration.source else {
            return
        }

        source.muted = muted
        configuration.source = source
        persistCurrentSourceIfNeeded(source)
        controllers.forEach { $0.setMuted(muted) }
    }

    func close() {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        sourceFilePollTimer?.invalidate()
        sourceFilePollTimer = nil
        controllers.forEach { $0.close() }
        controllers.removeAll()
    }

    private func rebuildWindows() {
        controllers.forEach { $0.close() }

        let screens: [NSScreen]
        if configuration.debugWindow {
            screens = [NSScreen.main ?? NSScreen.screens.first].compactMap { $0 }
        } else {
            screens = NSScreen.screens
        }

        Diagnostics.log("rebuildWindows debug=\(configuration.debugWindow) screenCount=\(screens.count)")

        controllers = screens.map { screen in
            let controller = BackgroundWindowController(screen: screen, configuration: configuration)
            controller.showWindow(nil)
            return controller
        }
    }

    private func startSourceFilePollingIfNeeded() {
        guard let sourceFilePath = configuration.sourceFilePath else {
            return
        }

        lastSourceFileModificationDate = sourceFileModificationDate(at: sourceFilePath)
        sourceFilePollTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.reloadSourceFileIfChanged()
            }
        }
    }

    private func reloadSourceFileIfChanged() {
        guard let sourceFilePath = configuration.sourceFilePath else {
            return
        }

        let modificationDate = sourceFileModificationDate(at: sourceFilePath)
        guard modificationDate != lastSourceFileModificationDate else {
            return
        }

        lastSourceFileModificationDate = modificationDate
        reloadSourceFile(force: false)
    }

    private func reloadSourceFile(force: Bool) {
        guard let sourceFilePath = configuration.sourceFilePath else {
            return
        }

        do {
            var nextConfiguration = try AppConfigurationParser.loadSourceFile(at: sourceFilePath)
            nextConfiguration.debugWindow = configuration.debugWindow
            nextConfiguration.diagnosticsLogPath = configuration.diagnosticsLogPath

            let sourceChanged = nextConfiguration.source != configuration.source
                || nextConfiguration.statusMessage != configuration.statusMessage

            configuration = nextConfiguration
            lastSourceFileModificationDate = sourceFileModificationDate(at: sourceFilePath)

            if force || sourceChanged {
                Diagnostics.log("hot reloaded source=\(configuration.source?.youtubeVideoID.rawValue ?? "nil")")
                controllers.forEach { $0.reload(configuration: configuration) }
                onSourceChanged?()
            }
        } catch {
            Diagnostics.log("failed to hot reload source file: \(error.localizedDescription)")
        }
    }

    private func sourceFileModificationDate(at path: String) -> Date? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        return attributes?[.modificationDate] as? Date
    }

    private func persistCurrentSourceIfNeeded(_ source: ScenicSource) {
        guard let sourceFilePath = configuration.sourceFilePath else {
            return
        }

        let url = URL(fileURLWithPath: sourceFilePath)
        guard url.lastPathComponent == "current-source.json" else {
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let data = try encoder.encode(source)
            try data.write(to: url, options: .atomic)
            lastSourceFileModificationDate = sourceFileModificationDate(at: sourceFilePath)
            Diagnostics.log("persisted muted=\(source.muted) to \(sourceFilePath)")
        } catch {
            Diagnostics.log("failed to persist source settings: \(error.localizedDescription)")
        }
    }
}
