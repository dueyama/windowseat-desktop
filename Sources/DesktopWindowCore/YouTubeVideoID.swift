import Foundation

public struct YouTubeVideoID: RawRepresentable, Codable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public var description: String {
        rawValue
    }

    public init?(rawValue: String) {
        guard Self.isValid(rawValue) else {
            return nil
        }
        self.rawValue = rawValue
    }

    public init?(_ candidate: String) {
        self.init(rawValue: candidate)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let videoID = Self(value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an 11-character YouTube video ID."
            )
        }
        self = videoID
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public static func isValid(_ candidate: String) -> Bool {
        guard candidate.count == 11 else {
            return false
        }

        return candidate.unicodeScalars.allSatisfy { scalar in
            switch scalar.value {
            case 48...57, 65...90, 97...122:
                return true
            case 45, 95:
                return true
            default:
                return false
            }
        }
    }
}
