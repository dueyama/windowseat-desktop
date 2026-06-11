import AppKit

final class DesktopBackgroundWindow: NSWindow {
    override var canBecomeKey: Bool {
        styleMask.contains(.titled)
    }

    override var canBecomeMain: Bool {
        styleMask.contains(.titled)
    }
}
