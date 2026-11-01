import JournalingSuggestions
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var existing: JournalEntry?

    @State private var title = ""
    @State private var bodyText = ""
    @State private var prompt: String?
    @State private var placeName: String?
    @State private var momentStart: Date?
    @State private var momentEnd: Date?
    @State private var kindLine: String?
    @State private var newImages: [Data] = []
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let prompt, !prompt.isEmpty {
                        Text(prompt)
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(Color.tide)
                    }
                    TextField("Title", text: $title)
                        .font(.system(.title2, design: .serif))
                    if let placeName {
                        Label(placeName, systemImage: "mappin")
                            .font(.footnote)
                            .foregroundStyle(Color.ink.opacity(0.65))
                    }
                    if let kindLine {
                        Text(kindLine)
                            .font(.caption)
                            .foregroundStyle(Color.ink.opacity(0.5))
                    }
                    TextField("Write", text: $bodyText, axis: .vertical)
                        .lineLimit(8...24)
                    imageStrip
                    HStack(spacing: 12) {
                        JournalingSuggestionsPicker {
                            Label("Moments", systemImage: "sparkles")
                        } onCompletion: { suggestion in
                            let draft = await SuggestionImporter.makeDraft(from: suggestion)
                            await MainActor.run {
                                title = draft.title
                                prompt = draft.prompt
                                placeName = draft.placeName
                                momentStart = draft.momentStart
                                momentEnd = draft.momentEnd
                                kindLine = draft.kindLine
                                newImages.append(contentsOf: draft.images)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.tide)

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Label("Photo", systemImage: "photo")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.ink)
                    }
                }
                .padding(20)
            }
            .background(Color.paper)
            .navigationTitle(existing == nil ? "New entry" : "Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear(perform: loadExisting)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        newImages.append(data)
                    }
                    photoItem = nil
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !newImages.isEmpty
            || !(existing?.images.isEmpty ?? true)
    }

    private var imageStrip: some View {
        let existingImages = existing?.images.sorted(by: { $0.createdAt < $1.createdAt }) ?? []
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(existingImages) { image in
                    thumb(data: image.data)
                }
                ForEach(Array(newImages.enumerated()), id: \.offset) { _, data in
                    thumb(data: data)
                }
            }
        }
    }

    private func thumb(data: Data) -> some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 92, height: 92)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func loadExisting() {
        guard let existing else { return }
        title = existing.title
        bodyText = existing.bodyText
        prompt = existing.prompt
        placeName = existing.placeName
        momentStart = existing.momentStart
        momentEnd = existing.momentEnd
    }

    private func save() {
        let entry: JournalEntry
        if let existing {
            entry = existing
            entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.bodyText = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.prompt = prompt
            entry.placeName = placeName
            entry.momentStart = momentStart
            entry.momentEnd = momentEnd
        } else {
            entry = JournalEntry(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                bodyText: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
                momentStart: momentStart,
                momentEnd: momentEnd,
                placeName: placeName,
                prompt: prompt
            )
            context.insert(entry)
        }
        for data in newImages {
            let image = EntryImage(data: data)
            image.entry = entry
            context.insert(image)
        }
        dismiss()
    }
}
