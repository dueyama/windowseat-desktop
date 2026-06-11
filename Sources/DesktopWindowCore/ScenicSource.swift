import Foundation

public struct ScenicSource: Codable, Equatable, Sendable {
    public var title: String
    public var youtubeVideoID: YouTubeVideoID
    public var fillMode: FillMode
    public var muted: Bool
    public var showOverlay: Bool
    public var sourceKind: SourceKind?
    public var preferredQuality: PlaybackQuality
    public var selectedBy: String?
    public var selectedAt: String?
    public var agentNote: AgentNote?
    public var quote: ScenicQuote?

    public init(
        title: String,
        youtubeVideoID: YouTubeVideoID,
        fillMode: FillMode = .fill,
        muted: Bool = true,
        showOverlay: Bool = false,
        sourceKind: SourceKind? = nil,
        preferredQuality: PlaybackQuality = .highres,
        selectedBy: String? = nil,
        selectedAt: String? = nil,
        agentNote: AgentNote? = nil,
        quote: ScenicQuote? = nil
    ) {
        self.title = title
        self.youtubeVideoID = youtubeVideoID
        self.fillMode = fillMode
        self.muted = muted
        self.showOverlay = showOverlay
        self.sourceKind = sourceKind
        self.preferredQuality = preferredQuality
        self.selectedBy = selectedBy
        self.selectedAt = selectedAt
        self.agentNote = agentNote
        self.quote = quote
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case youtubeVideoID
        case fillMode
        case muted
        case showOverlay
        case sourceKind
        case preferredQuality
        case selectedBy
        case selectedAt
        case agentNote
        case quote
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        youtubeVideoID = try container.decode(YouTubeVideoID.self, forKey: .youtubeVideoID)
        fillMode = try container.decodeIfPresent(FillMode.self, forKey: .fillMode) ?? .fill
        muted = try container.decodeIfPresent(Bool.self, forKey: .muted) ?? true
        showOverlay = try container.decodeIfPresent(Bool.self, forKey: .showOverlay) ?? false
        sourceKind = try container.decodeIfPresent(SourceKind.self, forKey: .sourceKind)
        preferredQuality = try container.decodeIfPresent(PlaybackQuality.self, forKey: .preferredQuality) ?? .highres
        selectedBy = try container.decodeIfPresent(String.self, forKey: .selectedBy)
        selectedAt = try container.decodeIfPresent(String.self, forKey: .selectedAt)
        agentNote = try container.decodeIfPresent(AgentNote.self, forKey: .agentNote)
        quote = try container.decodeIfPresent(ScenicQuote.self, forKey: .quote)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(youtubeVideoID, forKey: .youtubeVideoID)
        try container.encode(fillMode, forKey: .fillMode)
        try container.encode(muted, forKey: .muted)
        try container.encode(showOverlay, forKey: .showOverlay)
        try container.encodeIfPresent(sourceKind, forKey: .sourceKind)
        try container.encode(preferredQuality, forKey: .preferredQuality)
        try container.encodeIfPresent(selectedBy, forKey: .selectedBy)
        try container.encodeIfPresent(selectedAt, forKey: .selectedAt)
        try container.encodeIfPresent(agentNote, forKey: .agentNote)
        try container.encodeIfPresent(quote, forKey: .quote)
    }
}

public enum SourceKind: String, Codable, Equatable, Sendable {
    case live
    case recording
    case unknown
}

public enum PlaybackQuality: String, Codable, Equatable, Sendable {
    case auto
    case large
    case hd720
    case hd1080
    case highres
}

public struct AgentNote: Codable, Equatable, Sendable {
    public var headline: String
    public var body: String

    public init(headline: String, body: String) {
        self.headline = headline
        self.body = body
    }
}

public struct ScenicQuote: Codable, Equatable, Sendable {
    public var text: String
    public var attribution: String?

    public init(text: String, attribution: String? = nil) {
        self.text = text
        self.attribution = attribution
    }
}

public struct SourceList: Codable, Equatable, Sendable {
    public var sources: [ScenicSource]

    public init(sources: [ScenicSource]) {
        self.sources = sources
    }
}
