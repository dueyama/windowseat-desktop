import AppKit
import DesktopWindowCore

@MainActor
final class StatusMenuController {
    private let statusItem: NSStatusItem
    private let sourceProvider: () -> ScenicSource?
    private let bookmarksProvider: () -> [ScenicSource]
    private let onReload: () -> Void
    private let onSetMuted: (Bool) -> Void
    private let onBookmarkCurrent: () -> Void
    private let onApplyBookmark: (ScenicSource) -> Void
    private let statusMessage: String?

    init(
        configuration: AppConfiguration,
        sourceProvider: @escaping () -> ScenicSource?,
        onReload: @escaping () -> Void,
        onSetMuted: @escaping (Bool) -> Void,
        bookmarksProvider: @escaping () -> [ScenicSource],
        onBookmarkCurrent: @escaping () -> Void,
        onApplyBookmark: @escaping (ScenicSource) -> Void
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.sourceProvider = sourceProvider
        self.onReload = onReload
        self.onSetMuted = onSetMuted
        self.bookmarksProvider = bookmarksProvider
        self.onBookmarkCurrent = onBookmarkCurrent
        self.onApplyBookmark = onApplyBookmark
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

    @objc private func bookmarkCurrent() {
        onBookmarkCurrent()
        rebuildMenu()
    }

    @objc private func applyBookmark(_ sender: NSMenuItem) {
        guard let index = sender.representedObject as? Int else {
            return
        }

        let bookmarks = bookmarksProvider()
        guard bookmarks.indices.contains(index) else {
            return
        }

        onApplyBookmark(bookmarks[index])
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
        let bookmarks = bookmarksProvider()
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

        menu.addItem(.separator())

        let bookmarkItem = NSMenuItem(title: "Bookmark This Window", action: #selector(bookmarkCurrent), keyEquivalent: "b")
        bookmarkItem.target = self
        bookmarkItem.isEnabled = source != nil
        if let source, bookmarks.contains(where: { $0.youtubeVideoID == source.youtubeVideoID }) {
            bookmarkItem.state = .on
        }
        menu.addItem(bookmarkItem)

        let bookmarksItem = NSMenuItem(title: "Bookmarks", action: nil, keyEquivalent: "")
        bookmarksItem.submenu = bookmarksMenu(currentSource: source, bookmarks: bookmarks)
        bookmarksItem.isEnabled = true
        menu.addItem(bookmarksItem)

        menu.addItem(.separator())

        let reloadItem = NSMenuItem(title: "Reload", action: #selector(reload), keyEquivalent: "r")
        reloadItem.target = self
        menu.addItem(reloadItem)

        let quitItem = NSMenuItem(title: "Quit WindowSeat", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func bookmarksMenu(currentSource: ScenicSource?, bookmarks: [ScenicSource]) -> NSMenu {
        let menu = NSMenu(title: "Bookmarks")
        menu.autoenablesItems = false

        guard !bookmarks.isEmpty else {
            let emptyItem = NSMenuItem(title: "No Bookmarks", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
            return menu
        }

        for (index, bookmark) in bookmarks.enumerated() {
            let item = NSMenuItem(title: bookmark.title, action: #selector(applyBookmark(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = index
            item.isEnabled = true

            if currentSource?.youtubeVideoID == bookmark.youtubeVideoID {
                item.state = .on
            }

            menu.addItem(item)
        }

        return menu
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
