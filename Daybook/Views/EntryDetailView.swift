import SwiftData
import SwiftUI
import UIKit

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var entry: JournalEntry
    @State private var editing = false
    @State private var confirmDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.createdAt.formatted(date: .complete, time: .shortened))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.ink.opacity(0.55))
                if let start = entry.momentStart {
                    Text("Moment \(start.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(Color.tide)
                }
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.system(.largeTitle, design: .serif))
                        .foregroundStyle(Color.ink)
                }
                if let prompt = entry.prompt, !prompt.isEmpty {
                    Text(prompt)
                        .font(.system(.title3, design: .serif).italic())
                        .foregroundStyle(Color.tide)
                }
                if let place = entry.placeName {
                    Label(place, systemImage: "mappin")
                        .font(.subheadline)
                        .foregroundStyle(Color.ink.opacity(0.7))
                }
                ForEach(entry.images.sorted(by: { $0.createdAt < $1.createdAt })) { image in
                    if let uiImage = UIImage(data: image.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                if !entry.bodyText.isEmpty {
                    Text(entry.bodyText)
                        .font(.body)
                        .foregroundStyle(Color.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
        }
        .background(Color.paper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(entry.bookmarked ? "Bookmarked" : "Bookmark") {
                    entry.bookmarked.toggle()
                }
                .tint(Color.tide)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit") { editing = true }
                    Button("Delete", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .tint(Color.ink)
            }
        }
        .sheet(isPresented: $editing) {
            ComposerView(existing: entry)
        }
        .confirmationDialog("Delete this entry?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(entry)
                dismiss()
            }
        }
    }
}
