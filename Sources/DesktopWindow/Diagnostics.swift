import Foundation

@MainActor
enum Diagnostics {
    private static var logURL: URL?

    static func configure(path: String?) {
        guard let path, !path.isEmpty else {
            return
        }

        logURL = URL(fileURLWithPath: path)
        log("diagnostics started")
    }

    static func log(_ message: String) {
        let line = "[\(Date())] \(message)\n"

        if let logURL {
            if let data = line.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: logURL.path) {
                    if let handle = try? FileHandle(forWritingTo: logURL) {
                        _ = try? handle.seekToEnd()
                        try? handle.write(contentsOf: data)
                        try? handle.close()
                    }
                } else {
                    try? data.write(to: logURL)
                }
            }
        } else {
            return
        }
    }
}
