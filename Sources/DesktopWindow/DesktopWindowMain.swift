import AppKit

@main
enum DesktopWindowMain {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        let delegate = DesktopWindowApp()
        application.delegate = delegate
        delegate.startIfNeeded()
        application.finishLaunching()

        withExtendedLifetime(delegate) {
            application.run()
        }
    }
}
