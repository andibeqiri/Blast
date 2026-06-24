import SwiftUI

struct BookmarkRow: View {
    let bookmark: Bookmark
    let onTap: () -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: bookmark.icon)
                    .frame(width: 24)
                    .foregroundStyle(theme.secondaryText)
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.title)
                        .foregroundStyle(theme.primaryText)
                    Text(bookmark.url)
                        .font(.caption)
                        .foregroundStyle(theme.tertiaryText)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(theme.tertiaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
