import Foundation
import JournalingSuggestions

struct EntryDraft: Sendable {
    var title: String
    var placeName: String?
    var prompt: String?
    var momentStart: Date?
    var momentEnd: Date?
    var images: [Data]
    var kindLine: String?
}

enum SuggestionImporter {
    /// Copy suggestion assets immediately. The photo URLs are only valid inside this call.
    static func makeDraft(from suggestion: JournalingSuggestion) async -> EntryDraft {
        let photos = await suggestion.content(forType: JournalingSuggestion.Photo.self)
        var imageData: [Data] = []
        imageData.reserveCapacity(photos.count)
        for photo in photos {
            if let data = readFile(at: photo.photo) {
                imageData.append(data)
            }
        }

        let locations = await suggestion.content(forType: JournalingSuggestion.Location.self)
        let place = locations.compactMap { location -> String? in
            let parts = [location.place, location.city].compactMap { $0 }
            return parts.isEmpty ? nil : parts.joined(separator: ", ")
        }.first

        let reflections = await suggestion.content(forType: JournalingSuggestion.Reflection.self)
        let prompt = reflections.first?.prompt

        let kinds = suggestion.items
            .flatMap(\.representations)
            .map { String(describing: $0) }
        var seen = Set<String>()
        let uniqueKinds = kinds.filter { seen.insert($0).inserted }

        return EntryDraft(
            title: suggestion.title,
            placeName: place,
            prompt: prompt,
            momentStart: suggestion.date?.start,
            momentEnd: suggestion.date?.end,
            images: imageData,
            kindLine: uniqueKinds.isEmpty ? nil : uniqueKinds.joined(separator: " · ")
        )
    }

    private static func readFile(at url: URL) -> Data? {
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try? Data(contentsOf: url)
    }
}
