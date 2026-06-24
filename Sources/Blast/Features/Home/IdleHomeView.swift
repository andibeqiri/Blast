import SwiftUI

// MARK: - Idle home screen

struct IdleHomeView: View {
    let vm: PaletteViewModel
    @Environment(\.theme) private var theme

    @State private var appeared = false

    private let tips: [(icon: String, text: String)] = [
        ("play.rectangle", "yt lo-fi beats"),
        ("magnifyingglass", "g swift concurrency"),
        ("chevron.left.forwardslash.chevron.right", "gh apple"),
        ("sparkles", "what is the best iOS font?"),
    ]

    private let recents: [(icon: String, title: String, url: String)] = [
        ("chevron.left.forwardslash.chevron.right", "GitHub",         "github.com"),
        ("paintbrush",                              "Figma",          "figma.com"),
        ("newspaper",                               "Hacker News",    "news.ycombinator.com"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            logo
            Spacer().frame(height: 48)
            tipsSection
            Spacer().frame(height: 36)
            recentsSection
            Spacer()
            // Reserve space for the command bar
            Spacer().frame(height: 72)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.05)) {
                appeared = true
            }
        }
        .onDisappear { appeared = false }
    }

    // MARK: Logo

    private var logo: some View {
        VStack(spacing: 14) {
            ZStack {
                // Glow ring
                Circle()
                    .fill(theme.navigationAccent.opacity(0.12))
                    .frame(width: 88, height: 88)
                    .blur(radius: 18)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.navigationAccent.opacity(0.25), theme.askAccent.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay {
                        Circle()
                            .strokeBorder(theme.navigationAccent.opacity(0.3), lineWidth: 1)
                    }

                Image(systemName: "bolt.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.navigationAccent, theme.askAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            Text("Blast")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.primaryText)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 6)
                .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.08), value: appeared)

            Text("Open, search, or ask anything")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 6)
                .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.13), value: appeared)
        }
    }

    // MARK: Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Try typing", systemImage: "lightbulb")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.tertiaryText)
                .textCase(.uppercase)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.2).delay(0.18), value: appeared)

            FlowLayout(spacing: 8) {
                ForEach(Array(tips.enumerated()), id: \.offset) { i, tip in
                    TipChip(icon: tip.icon, text: tip.text)
                        .onTapGesture { vm.inputText = tip.text }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.8).delay(0.2 + Double(i) * 0.06),
                            value: appeared
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Recents

    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recent", systemImage: "clock")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.tertiaryText)
                .textCase(.uppercase)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.2).delay(0.38), value: appeared)

            VStack(spacing: 2) {
                ForEach(Array(recents.enumerated()), id: \.offset) { i, item in
                    RecentRow(icon: item.icon, title: item.title, url: item.url)
                        .onTapGesture { vm.openBookmark(
                            Bookmark(title: item.title, url: item.url, icon: item.icon)
                        )}
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.8).delay(0.42 + Double(i) * 0.07),
                            value: appeared
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Tip chip

struct TipChip: View {
    let icon: String
    let text: String
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(theme.navigationAccent)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(theme.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(theme.navigationAccent.opacity(0.08), in: Capsule())
        .overlay { Capsule().strokeBorder(theme.navigationAccent.opacity(0.18), lineWidth: 1) }
    }
}

// MARK: - Recent row

struct RecentRow: View {
    let icon: String
    let title: String
    let url: String
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(theme.secondaryText)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)
                Text(url)
                    .font(.caption)
                    .foregroundStyle(theme.tertiaryText)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundStyle(theme.tertiaryText)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Simple flow layout for chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + CGFloat(max(rows.count - 1, 0)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for entry in row.entries {
                entry.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(entry.size))
                x += entry.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var entries: [(view: LayoutSubview, size: CGSize)]
        var height: CGFloat { entries.map(\.size.height).max() ?? 0 }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row(entries: [])
        var currentWidth: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            let needed = currentWidth == 0 ? size.width : currentWidth + spacing + size.width
            if needed > maxWidth && !current.entries.isEmpty {
                rows.append(current)
                current = Row(entries: [(view, size)])
                currentWidth = size.width
            } else {
                current.entries.append((view, size))
                currentWidth = needed
            }
        }
        if !current.entries.isEmpty { rows.append(current) }
        return rows
    }
}
