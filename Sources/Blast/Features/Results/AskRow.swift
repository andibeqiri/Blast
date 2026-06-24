import SwiftUI

struct AskRow: View {
    let query: String
    let answer: String?
    let isThinking: Bool
    let onTap: () -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isThinking {
                ShimmerView()
                    .frame(height: 44)
                    .clipShape(.rect(cornerRadius: 8))
            } else if let answer {
                Text(answer)
                    .foregroundStyle(theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Button(action: onTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(theme.askAccent)
                            .frame(width: 24)
                        Text("Ask: \"\(query)\"")
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
    }
}
