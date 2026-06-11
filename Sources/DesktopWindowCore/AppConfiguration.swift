import Foundation

public struct AppConfiguration: Equatable, Sendable {
    public var source: ScenicSource?
    public var sourceFilePath: String?
    public var debugWindow: Bool
    public var statusMessage: String?
    public var diagnosticsLogPath: String?

    public init(
        source: ScenicSource? = nil,
        sourceFilePath: String? = nil,
        debugWindow: Bool = false,
        statusMessage: String? = nil,
        diagnosticsLogPath: String? = nil
    ) {
        self.source = source
        self.sourceFilePath = sourceFilePath
        self.debugWindow = debugWindow
        self.statusMessage = statusMessage
        self.diagnosticsLogPath = diagnosticsLogPath
    }
}

public enum ConfigurationError: Error, Equatable, LocalizedError {
    case missingValue(String)
    case unknownArgument(String)
    case invalidVideoID(String)
    case invalidFillMode(String)
    case unreadableSourceFile(String)
    case emptySourceFile(String)

    public var errorDescription: String? {
        switch self {
        case .missingValue(let argument):
            return "Missing value for \(argument)."
        case .unknownArgument(let argument):
            return "Unknown argument: \(argument)."
        case .invalidVideoID(let value):
            return "Invalid YouTube video ID: \(value)."
        case .invalidFillMode(let value):
            return "Invalid fill mode: \(value). Use fill or fit."
        case .unreadableSourceFile(let message):
            return "Could not read source file: \(message)."
        case .emptySourceFile(let path):
            return "Source file has no sources: \(path)."
        }
    }
}

public enum AppConfigurationParser {
    public static let helpText = """
    Usage:
      DesktopWindow --video-id VIDEO_ID [--fill-mode fill|fit] [--debug-window]
      DesktopWindow --source-file Config/sources.json [--debug-window]
      DesktopWindow --source-file Config/current-source.json
      DesktopWindow --source-file Config/sources.json [--diagnostics-log /tmp/DesktopWindow.log]

    Environment:
      DESKTOP_WINDOW_VIDEO_ID=VIDEO_ID
    """

    public static func parse(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> AppConfiguration {
        var videoIDValue: String?
        var sourceFilePath: String?
        var fillMode = FillMode.fill
        var debugWindow = false
        var diagnosticsLogPath: String?

        var index = 1
        while index < arguments.count {
            let argument = arguments[index]

            switch argument {
            case "--video-id":
                index += 1
                guard index < arguments.count else {
                    throw ConfigurationError.missingValue(argument)
                }
                videoIDValue = arguments[index]
            case "--source-file":
                index += 1
                guard index < arguments.count else {
                    throw ConfigurationError.missingValue(argument)
                }
                sourceFilePath = arguments[index]
            case "--fill-mode":
                index += 1
                guard index < arguments.count else {
                    throw ConfigurationError.missingValue(argument)
                }
                guard let parsedFillMode = FillMode(rawValue: arguments[index]) else {
                    throw ConfigurationError.invalidFillMode(arguments[index])
                }
                fillMode = parsedFillMode
            case "--debug-window":
                debugWindow = true
            case "--diagnostics-log":
                index += 1
                guard index < arguments.count else {
                    throw ConfigurationError.missingValue(argument)
                }
                diagnosticsLogPath = arguments[index]
            case "--help", "-h":
                return AppConfiguration(
                    debugWindow: true,
                    statusMessage: helpText,
                    diagnosticsLogPath: diagnosticsLogPath
                )
            default:
                throw ConfigurationError.unknownArgument(argument)
            }

            index += 1
        }

        if let sourceFilePath {
            var configuration = try loadSourceFile(at: sourceFilePath)
            configuration.sourceFilePath = sourceFilePath
            configuration.debugWindow = debugWindow
            configuration.diagnosticsLogPath = diagnosticsLogPath
            return configuration
        }

        if videoIDValue == nil {
            videoIDValue = environment["DESKTOP_WINDOW_VIDEO_ID"]
        }

        guard let videoIDValue, !videoIDValue.isEmpty else {
            return AppConfiguration(
                debugWindow: debugWindow,
                statusMessage: "Run with --video-id VIDEO_ID, or ask an AI agent to create Config/current-source.json and run scripts/run-current.sh.",
                diagnosticsLogPath: diagnosticsLogPath
            )
        }

        guard let videoID = YouTubeVideoID(videoIDValue) else {
            throw ConfigurationError.invalidVideoID(videoIDValue)
        }

        return AppConfiguration(
            source: ScenicSource(
                title: "YouTube \(videoID.rawValue)",
                youtubeVideoID: videoID,
                fillMode: fillMode
            ),
            debugWindow: debugWindow,
            diagnosticsLogPath: diagnosticsLogPath
        )
    }

    public static func loadSourceFile(at path: String) throws -> AppConfiguration {
        let url = URL(fileURLWithPath: path)

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ConfigurationError.unreadableSourceFile(error.localizedDescription)
        }

        let decoder = JSONDecoder()

        do {
            let sourceList = try decoder.decode(SourceList.self, from: data)
            guard let firstSource = sourceList.sources.first else {
                throw ConfigurationError.emptySourceFile(path)
            }
            return AppConfiguration(source: firstSource, sourceFilePath: path)
        } catch {
            do {
                return AppConfiguration(
                    source: try decoder.decode(ScenicSource.self, from: data),
                    sourceFilePath: path
                )
            } catch {
                throw ConfigurationError.unreadableSourceFile(error.localizedDescription)
            }
        }
    }
}
