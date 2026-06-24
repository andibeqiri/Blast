import SwiftUI

// MARK: - Full-screen destination sheet

struct DestinationView: View {
    let destination: Destination
    let theme: Theme
    let onDismiss: () -> Void

    @State private var loadProgress: CGFloat = 0
    @State private var isLoaded = false

    var body: some View {
        ZStack(alignment: .top) {
            pageCanvas
            VStack(spacing: 0) {
                chrome
                if !isLoaded {
                    progressBar
                }
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(theme.destinationBackground)
        .environment(\.theme, theme)
        .onAppear { simulateLoad() }
    }

    // MARK: Chrome bar

    private var chrome: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08), in: Circle())
            }

            HStack(spacing: 8) {
                Image(systemName: faviconIcon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(displayURL)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                Spacer()
                if isLoaded {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.green.opacity(0.8))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button {
                // share — demo only
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isLoaded)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(.clear)
                Rectangle()
                    .fill(accentGradient)
                    .frame(width: geo.size.width * loadProgress)
            }
            .frame(height: 2)
        }
        .frame(height: 2)
    }

    // MARK: Page canvas

    @ViewBuilder
    private var pageCanvas: some View {
        switch destination {
        case .page(let title, let url, let icon):
            MockPageView(title: title, url: url, icon: icon, isLoaded: isLoaded)
        case .search(let engine, let query, _):
            MockSearchView(engine: engine, query: query, isLoaded: isLoaded)
        case .answer(let query, let text):
            MockAnswerView(query: query, answer: text, isLoaded: isLoaded)
        }
    }

    // MARK: Helpers

    private var displayURL: String {
        switch destination {
        case .page(_, let url, _): return url
        case .search(_, _, let url): return url
        case .answer: return "ask.blast"
        }
    }

    private var faviconIcon: String {
        switch destination {
        case .page(_, _, let icon): return icon
        case .search(let engine, _, _):
            switch engine {
            case "YouTube": return "play.rectangle"
            case "GitHub": return "chevron.left.forwardslash.chevron.right"
            default: return "magnifyingglass"
            }
        case .answer: return "sparkles"
        }
    }

    private var accentGradient: LinearGradient {
        switch destination {
        case .answer:
            return LinearGradient(colors: theme.loadBarColors.reversed(), startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: theme.loadBarColors, startPoint: .leading, endPoint: .trailing)
        }
    }

    private func simulateLoad() {
        withAnimation(.easeIn(duration: 0.15)) { loadProgress = 0.3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.35)) { loadProgress = 0.85 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.2)) { loadProgress = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isLoaded = true }
        }
    }
}

// MARK: - Mock page views

struct MockPageView: View {
    let title: String
    let url: String
    let icon: String
    let isLoaded: Bool

    private let fakeRows = 6

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 180)
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.8))
                            Text(title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            Text(url)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                // Fake content rows
                ForEach(0..<fakeRows, id: \.self) { i in
                    SkeletonRow(index: i, isLoaded: isLoaded)
                }
            }
            .padding(16)
            .padding(.top, 120)
        }
    }
}

struct MockSearchView: View {
    let engine: String
    let query: String
    let isLoaded: Bool

    private let resultCount = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Search header
                HStack(spacing: 8) {
                    Text(engine)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("\"\(query)\"")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text("About 12,400,000 results (0.38 seconds)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                // Fake search results
                ForEach(0..<resultCount, id: \.self) { i in
                    SearchResultRow(index: i, query: query, isLoaded: isLoaded)
                }
            }
            .padding(16)
            .padding(.top, 120)
        }
    }
}

struct MockAnswerView: View {
    let query: String
    let answer: String
    let isLoaded: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Question
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(query)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Answer
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(answer)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineSpacing(4)

                        // Fake follow-up chips
                        if isLoaded {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(followUps, id: \.self) { followUp in
                                        Text(followUp)
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(.purple)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.purple.opacity(0.12), in: Capsule())
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [.purple.opacity(0.08), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.purple.opacity(0.2), lineWidth: 1)
                }
            }
            .padding(16)
            .padding(.top, 120)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLoaded)
    }

    private let followUps = ["Tell me more", "Simpler explanation", "Give an example", "Related topics"]
}

// MARK: - Skeleton / result rows

struct SkeletonRow: View {
    let index: Int
    let isLoaded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoaded {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .frame(height: 14)
                    .frame(maxWidth: index % 2 == 0 ? .infinity : 220)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .frame(height: 12)
                    .frame(maxWidth: 260)
            } else {
                ShimmerBar()
                ShimmerBar(width: 180)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.06), value: isLoaded)
    }
}

struct SearchResultRow: View {
    let index: Int
    let query: String
    let isLoaded: Bool

    private static let domains = ["wikipedia.org", "medium.com", "reddit.com", "stackoverflow.com", "docs.swift.org"]
    private static let titles = ["Introduction to", "Complete guide to", "Understanding", "How to use", "Advanced patterns in"]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isLoaded {
                Text(Self.domains[index % Self.domains.count])
                    .font(.caption)
                    .foregroundStyle(.green.opacity(0.7))
                Text("\(Self.titles[index % Self.titles.count]) \(query)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue.opacity(0.85))
                Text("A comprehensive overview covering the most important aspects, with examples and references to help you get started quickly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                ShimmerBar(width: 120, height: 10)
                ShimmerBar(height: 14)
                ShimmerBar(width: 240, height: 10)
            }
        }
        .padding(12)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.07), value: isLoaded)
    }
}

struct ShimmerBar: View {
    var width: CGFloat? = nil
    var height: CGFloat = 12

    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            let w = width ?? geo.size.width
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.05), location: phase - 0.3),
                    .init(color: .white.opacity(0.13), location: phase),
                    .init(color: .white.opacity(0.05), location: phase + 0.3),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: w)
            .clipShape(.rect(cornerRadius: 6))
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1.3
            }
        }
    }
}
