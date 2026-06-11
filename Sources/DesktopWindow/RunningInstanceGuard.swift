import Darwin
import Foundation
import AppKit

@MainActor
enum RunningInstanceGuard {
    private static let lockFileURL = URL(fileURLWithPath: "/tmp/windowseat-desktop.pid")

    static func acquire() {
        let currentPID = getpid()
        Diagnostics.log("single instance guard pidFile=\(lockFileURL.path) currentPID=\(currentPID)")

        for existingPID in existingInstancePIDs(excluding: currentPID) {
            terminatePreviousInstance(existingPID)
        }

        writePID(currentPID)
    }

    static func release() {
        let currentPID = getpid()
        guard readPID() == currentPID else {
            return
        }

        try? FileManager.default.removeItem(at: lockFileURL)
    }

    private static func readPID() -> pid_t? {
        guard
            let data = try? Data(contentsOf: lockFileURL),
            let text = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            let pid = Int32(text)
        else {
            return nil
        }

        return pid
    }

    private static func writePID(_ pid: pid_t) {
        let data = Data("\(pid)\n".utf8)
        do {
            try data.write(to: lockFileURL, options: .atomic)
            Diagnostics.log("wrote pid file pid=\(pid)")
        } catch {
            Diagnostics.log("failed to write pid file: \(error.localizedDescription)")
        }
    }

    private static func isProcessRunning(_ pid: pid_t) -> Bool {
        guard pid > 0 else {
            return false
        }

        if kill(pid, 0) == 0 {
            return true
        }

        return errno == EPERM
    }

    private static func waitForExit(of pid: pid_t, timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            guard isProcessRunning(pid) else {
                return
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

    private static func terminatePreviousInstance(_ pid: pid_t) {
        Diagnostics.log("terminating previous instance pid=\(pid)")
        _ = kill(pid, SIGTERM)
        waitForExit(of: pid, timeout: 2.0)

        guard isProcessRunning(pid) else {
            Diagnostics.log("previous instance exited pid=\(pid)")
            return
        }

        Diagnostics.log("force terminating previous instance pid=\(pid)")
        _ = kill(pid, SIGKILL)
        waitForExit(of: pid, timeout: 1.0)
    }

    private static func isWindowSeatProcess(_ pid: pid_t) -> Bool {
        guard let app = NSRunningApplication(processIdentifier: pid) else {
            return false
        }

        return isWindowSeatApplication(app)
    }

    private static func isWindowSeatApplication(_ app: NSRunningApplication) -> Bool {
        if app.localizedName == "DesktopWindow" || app.localizedName == "WindowSeat" {
            return true
        }

        return app.executableURL?.lastPathComponent == "DesktopWindow"
    }

    private static func existingInstancePIDs(excluding currentPID: pid_t) -> [pid_t] {
        var pids = Set<pid_t>()

        if let existingPID = readPID(), existingPID != currentPID {
            if isWindowSeatProcess(existingPID) {
                pids.insert(existingPID)
            } else {
                Diagnostics.log("ignoring stale pid file value=\(existingPID)")
            }
        }

        for app in NSWorkspace.shared.runningApplications where app.processIdentifier != currentPID {
            guard isWindowSeatApplication(app) else {
                continue
            }
            pids.insert(app.processIdentifier)
        }

        return pids.sorted()
    }
}
