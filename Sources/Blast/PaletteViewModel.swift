import SwiftUI

// MARK: - Domain types

struct Bookmark: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let icon: String
}

struct KeywordAction {
    let keyword: String
    let label: String
    let urlTemplate: String
}

enum Destination: Identifiable, Equatable {
    case page(title: String, url: String, icon: String)
    case search(engine: String, query: String, url: String)
    case answer(query: String, text: String)

    var id: String {
        switch self {
        case .page(_, let url, _): return "page:\(url)"
        case .search(let engine, let query, _): return "search:\(engine):\(query)"
        case .answer(let query, _): return "answer:\(query)"
        }
    }
}

enum PaletteState: Equatable {
    case dismissed
    case presenting
    case idle
    case filtering(String)
    case action(String)
    case asking(String)
    case thinking(String)
    case dismissing
}

// MARK: - ViewModel

@Observable
@MainActor
final class PaletteViewModel {

    var state: PaletteState = .dismissed
    var inputText: String = "" {
        didSet { route(inputText) }
    }
    var toastMessage: String? = nil
    var answerText: String? = nil
    var destination: Destination? = nil

    private(set) var filteredBookmarks: [Bookmark] = []
    private(set) var activeAction: KeywordAction? = nil

    private var thinkingTask: Task<Void, Never>? = nil

    // MARK: Static data

    let bookmarks: [Bookmark] = [
        Bookmark(title: "GitHub", url: "github.com", icon: "chevron.left.forwardslash.chevron.right"),
        Bookmark(title: "Linear", url: "linear.app", icon: "checklist"),
        Bookmark(title: "Figma", url: "figma.com", icon: "paintbrush"),
        Bookmark(title: "Notion", url: "notion.so", icon: "doc.text"),
        Bookmark(title: "Vercel", url: "vercel.com", icon: "bolt"),
        Bookmark(title: "Hacker News", url: "news.ycombinator.com", icon: "newspaper"),
        Bookmark(title: "Swift Forums", url: "forums.swift.org", icon: "swift"),
        Bookmark(title: "Apple Developer", url: "developer.apple.com", icon: "apple.logo"),
        Bookmark(title: "YouTube", url: "youtube.com", icon: "play.rectangle"),
        Bookmark(title: "Twitter / X", url: "x.com", icon: "bird"),
        Bookmark(title: "Stack Overflow", url: "stackoverflow.com", icon: "questionmark.circle"),
        Bookmark(title: "Anthropic", url: "anthropic.com", icon: "brain"),
    ]

    let keywordActions: [KeywordAction] = [
        KeywordAction(keyword: "yt", label: "Search YouTube", urlTemplate: "youtube.com/search?q="),
        KeywordAction(keyword: "g", label: "Search Google", urlTemplate: "google.com/search?q="),
        KeywordAction(keyword: "gh", label: "Search GitHub", urlTemplate: "github.com/search?q="),
    ]

    let stubAnswers: [String] = [
        "Based on what I know, the answer involves a few moving parts. The short version: yes, but with caveats.",
        "That's a great question. The consensus leans toward the second approach, mostly for performance reasons.",
        "Interesting. There are three main schools of thought here, and none of them fully agree.",
        "The honest answer is: it depends on your constraints. Happy to break it down further.",
    ]

    // MARK: Routing

    private func route(_ text: String) {
        thinkingTask?.cancel()
        thinkingTask = nil
        answerText = nil

        let trimmed = text.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            filteredBookmarks = []
            activeAction = nil
            state = .idle
            return
        }

        // Keyword action: starts with known token followed by space
        for action in keywordActions {
            if trimmed.lowercased().hasPrefix(action.keyword + " ") {
                let query = String(trimmed.dropFirst(action.keyword.count + 1))
                activeAction = KeywordAction(keyword: action.keyword, label: "\(action.label) for \"\(query)\"", urlTemplate: action.urlTemplate + query)
                filteredBookmarks = []
                state = .action(trimmed)
                return
            }
        }

        // Navigation: contains a dot or matches a bookmark prefix
        let lc = trimmed.lowercased()
        let matches = bookmarks.filter {
            $0.title.lowercased().contains(lc) || $0.url.lowercased().contains(lc)
        }
        if trimmed.contains(".") || !matches.isEmpty {
            filteredBookmarks = matches.isEmpty ? [] : matches
            activeAction = nil
            state = .filtering(trimmed)
            return
        }

        // Ask mode: ends in ? or has 3+ words
        let wordCount = trimmed.split(separator: " ").count
        if trimmed.hasSuffix("?") || wordCount >= 3 {
            filteredBookmarks = []
            activeAction = nil
            state = .asking(trimmed)
            return
        }

        // Default to filtering with no matches while the user builds a query
        filteredBookmarks = []
        activeAction = nil
        state = .filtering(trimmed)
    }

    // MARK: Actions

    func execute() {
        switch state {
        case .asking(let query):
            if let answer = answerText {
                destination = .answer(query: query, text: answer)
            } else {
                state = .thinking(query)
                thinkingTask = Task {
                    try? await Task.sleep(for: .seconds(1.2))
                    guard !Task.isCancelled else { return }
                    let answer = stubAnswers.randomElement() ?? stubAnswers[0]
                    answerText = answer
                    state = .asking(query)
                }
            }
        case .action:
            if let action = activeAction {
                let parts = action.label.components(separatedBy: " for ")
                let engine = parts.first.map { String($0.replacing("Search ", with: "")) } ?? "Search"
                let query = parts.last.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) } ?? ""
                destination = .search(engine: engine, query: query, url: action.urlTemplate)
            }
        case .filtering:
            if let first = filteredBookmarks.first {
                destination = .page(title: first.title, url: first.url, icon: first.icon)
            }
        default:
            break
        }
    }

    func openBookmark(_ bookmark: Bookmark) {
        destination = .page(title: bookmark.title, url: bookmark.url, icon: bookmark.icon)
    }

    func dismiss() {
        thinkingTask?.cancel()
        thinkingTask = nil
        state = .dismissing
        // Reset to idle after the spring settles so the screen never stays black
        Task {
            try? await Task.sleep(for: .milliseconds(480))
            inputText = ""
            answerText = nil
            state = .idle
        }
    }

    func present() {
        state = .idle
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2))
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }

    // MARK: Computed helpers

    var isAsking: Bool {
        if case .asking = state { return true }
        if case .thinking = state { return true }
        return false
    }

    var isThinking: Bool {
        if case .thinking = state { return true }
        return false
    }

    var accentColor: Color {
        isAsking ? Color.purple : Color.blue
    }

    var hintText: String {
        switch state {
        case .idle: return "Open, search, or ask…"
        case .asking: return "↵ to ask"
        case .thinking: return "thinking…"
        case .action: return "↵ to go"
        default: return "Open, search, or ask…"
        }
    }
}
