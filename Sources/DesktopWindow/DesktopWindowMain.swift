import AppKit

@main
enum DesktopWindowMain {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        let startsAsDebugWindow = CommandLine.arguments.contains("--debug-window")
        application.setActivationPolicy(startsAsDebugWindow ? .regular : .accessory)

        let delegate = DesktopWindowApp()
        application.delegate = delegate

        withExtendedLifetime(delegate) {
            application.run()
        }
    }
}
