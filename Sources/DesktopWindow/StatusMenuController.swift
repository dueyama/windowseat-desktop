import AppKit
import DesktopWindowCore

@MainActor
final class StatusMenuController {
    private let statusItem: NSStatusItem
    private let sourceProvider: () -> ScenicSource?
    private let onReload: () -> Void
    private let onSetMuted: (Bool) -> Void
    private let statusMessage: String?

    init(
        configuration: AppConfiguration,
        sourceProvider: @escaping () -> ScenicSource?,
        onReload: @escaping () -> Void,
        onSetMuted: @escaping (Bool) -> Void
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.sourceProvider = sourceProvider
        self.onReload = onReload
        self.onSetMuted = onSetMuted
        self.statusMessage = configuration.statusMessage

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mountain.2.fill", accessibilityDescription: "WindowSeat")
            button.title = button.image == nil ? "DW" : ""
        }

        rebuildMenu()
    }

    func refreshMenu() {
        rebuildMenu()
    }

    @objc private func reload() {
        onReload()
    }

    @objc private func toggleSound() {
        guard let source = sourceProvider() else {
            return
        }

        onSetMuted(!source.muted)
        rebuildMenu()
    }

    @objc private func openInYouTube() {
        guard
            let videoID = sourceProvider()?.youtubeVideoID.rawValue,
            let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)")
        else {
            return
        }

        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let source = sourceProvider()
        let sourceTitle = source?.title ?? "No source configured"
        let sourceItem = NSMenuItem(title: sourceTitle, action: nil, keyEquivalent: "")
        sourceItem.isEnabled = true
        menu.addItem(sourceItem)

        if let source {
            addAgentItems(for: source, to: menu)
        }

        if let message = statusMessage {
            let messageItem = NSMenuItem(title: message, action: nil, keyEquivalent: "")
            messageItem.isEnabled = true
            menu.addItem(messageItem)
        }

        menu.addItem(.separator())

        let soundTitle: String
        if let source {
            soundTitle = source.muted ? "Turn Sound On" : "Mute Sound"
        } else {
            soundTitle = "Sound Unavailable"
        }
        let soundItem = NSMenuItem(title: soundTitle, action: #selector(toggleSound), keyEquivalent: "m")
        soundItem.target = self
        soundItem.isEnabled = source != nil
        menu.addItem(soundItem)

        let openItem = NSMenuItem(title: "Open in YouTube", action: #selector(openInYouTube), keyEquivalent: "y")
        openItem.target = self
        openItem.isEnabled = source != nil
        menu.addItem(openItem)

        let reloadItem = NSMenuItem(title: "Reload", action: #selector(reload), keyEquivalent: "r")
        reloadItem.target = self
        menu.addItem(reloadItem)

        let quitItem = NSMenuItem(title: "Quit WindowSeat", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func addAgentItems(for source: ScenicSource, to menu: NSMenu) {
        guard source.agentNote != nil || source.quote != nil else {
            return
        }

        menu.addItem(.separator())

        let headerItem = NSMenuItem(title: "Today's Window", action: nil, keyEquivalent: "")
        headerItem.isEnabled = true
        menu.addItem(headerItem)

        if let note = source.agentNote {
            addDisabledWrappedItems(note.headline, to: menu, prefix: "")
            addDisabledWrappedItems(note.body, to: menu, prefix: "  ")
        }

        if let quote = source.quote {
            let quoteText = quote.attribution.map { "\(quote.text) - \($0)" } ?? quote.text
            addDisabledWrappedItems(quoteText, to: menu, prefix: "  ")
        }
    }

    private func addDisabledWrappedItems(_ text: String, to menu: NSMenu, prefix: String) {
        for line in Self.wrappedMenuLines(text, width: 34) {
            let item = NSMenuItem(title: "\(prefix)\(line)", action: nil, keyEquivalent: "")
            item.isEnabled = true
            menu.addItem(item)
        }
    }

    private static func wrappedMenuLines(_ text: String, width: Int) -> [String] {
        var lines: [String] = []
        var current = ""

        for character in text {
            if current.count >= width {
                lines.append(current)
                current = ""
            }
            current.append(character)
        }

        if !current.isEmpty {
            lines.append(current)
        }

        return lines.isEmpty ? [text] : lines
    }
}
