import Foundation
import SwiftData

@Model
final class JournalEntry {
    var title: String
    var bodyText: String
    var createdAt: Date
    var momentStart: Date?
    var momentEnd: Date?
    var bookmarked: Bool
    var placeName: String?
    var prompt: String?
    @Relationship(deleteRule: .cascade, inverse: \EntryImage.entry)
    var images: [EntryImage]

    init(
        title: String = "",
        bodyText: String = "",
        createdAt: Date = .now,
        momentStart: Date? = nil,
        momentEnd: Date? = nil,
        bookmarked: Bool = false,
        placeName: String? = nil,
        prompt: String? = nil
    ) {
        self.title = title
        self.bodyText = bodyText
        self.createdAt = createdAt
        self.momentStart = momentStart
        self.momentEnd = momentEnd
        self.bookmarked = bookmarked
        self.placeName = placeName
        self.prompt = prompt
        self.images = []
    }
}

@Model
final class EntryImage {
    var data: Data
    var createdAt: Date
    var entry: JournalEntry?

    init(data: Data, createdAt: Date = .now) {
        self.data = data
        self.createdAt = createdAt
    }
}
