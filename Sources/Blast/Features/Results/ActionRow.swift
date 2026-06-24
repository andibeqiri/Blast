import SwiftUI

struct ActionRow: View {
    let action: KeywordAction
    let onTap: () -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .foregroundStyle(theme.actionAccent)
                    .frame(width: 24)
                Text(action.label)
                    .foregroundStyle(theme.primaryText)
                Spacer()
                Text("↵")
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
