import Foundation

public enum SourceBookmarkStore {
    public static func load(from url: URL) throws -> [ScenicSource] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SourceList.self, from: data).sources
    }

    public static func save(_ sources: [ScenicSource], to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(SourceList(sources: sources))
        try data.write(to: url, options: .atomic)
    }

    public static func upserting(_ source: ScenicSource, into sources: [ScenicSource]) -> [ScenicSource] {
        var nextSources = sources.filter { $0.youtubeVideoID != source.youtubeVideoID }
        nextSources.insert(source, at: 0)
        return nextSources
    }
}
