import SwiftData
import SwiftUI
import UIKit

struct FeedView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    var lock: () -> Void

    @State private var query = ""
    @State private var filter: EntryFilter = .all
    @State private var composing = false

    private var visible: [JournalEntry] {
        entries.filter { entry in
            switch filter {
            case .all:
                break
            case .bookmarked:
                if !entry.bookmarked { return false }
            case .photos:
                if entry.images.isEmpty { return false }
            case .places:
                if entry.placeName == nil { return false }
            }
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !needle.isEmpty else { return true }
            let haystack = [entry.title, entry.bodyText, entry.placeName ?? "", entry.prompt ?? ""]
                .joined(separator: "\n")
            return haystack.localizedCaseInsensitiveContains(needle)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    header
                    filterRow
                    if visible.isEmpty {
                        empty
                    } else {
                        ForEach(visible) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(entry.bookmarked ? "Remove bookmark" : "Bookmark") {
                                    entry.bookmarked.toggle()
                                }
                                Button("Delete", role: .destructive) {
                                    context.delete(entry)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color.paper)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: lock) {
                        Image(systemName: "lock")
                    }
                    .tint(Color.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        composing = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .tint(Color.tide)
                }
            }
            .searchable(text: $query, prompt: "Search entries")
            .sheet(isPresented: $composing) {
                ComposerView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now.formatted(.dateTime.weekday(.wide)))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.tide)
                .padding(.top, 8)
            Text("Daybook")
                .font(.system(size: 36, weight: .medium, design: .serif))
                .foregroundStyle(Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EntryFilter.allCases) { item in
                    Button(item.title) {
                        filter = item
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(filter == item ? Color.tide : Color.card, in: Capsule())
                    .foregroundStyle(filter == item ? Color.paper : Color.ink)
                }
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entries.isEmpty ? "Nothing written yet." : "Nothing matches.")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.ink)
            Text("New entry is a blank page. Moments pulls photos, workouts, places, music, and prompts from this iPhone. The Simulator has none of that.")
                .font(.subheadline)
                .foregroundStyle(Color.ink.opacity(0.68))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private enum EntryFilter: String, CaseIterable, Identifiable {
    case all, bookmarked, photos, places

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .bookmarked: "Bookmarked"
        case .photos: "Photos"
        case .places: "Places"
        }
    }
}

private struct EntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.ink.opacity(0.55))
                Spacer()
                if entry.bookmarked {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(Color.tide)
                }
            }
            if !entry.title.isEmpty {
                Text(entry.title)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.ink)
            }
            if let prompt = entry.prompt, !prompt.isEmpty {
                Text(prompt)
                    .font(.subheadline.italic())
                    .foregroundStyle(Color.tide)
                    .lineLimit(2)
            }
            if !entry.bodyText.isEmpty {
                Text(entry.bodyText)
                    .font(.body)
                    .foregroundStyle(Color.ink.opacity(0.84))
                    .lineLimit(4)
            }
            if let place = entry.placeName {
                Label(place, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(Color.ink.opacity(0.6))
            }
            if let first = entry.images.sorted(by: { $0.createdAt < $1.createdAt }).first,
               let image = UIImage(data: first.data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .leading) {
            if entry.bookmarked {
                Rectangle()
                    .fill(Color.tide)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
    }
}
