import SwiftUI

struct ResultsList: View {
    let vm: PaletteViewModel
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                switch vm.state {
                case .action:
                    if let action = vm.activeAction {
                        ActionRow(action: action) { vm.execute() }
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                case .filtering:
                    ForEach(vm.filteredBookmarks) { bookmark in
                        BookmarkRow(bookmark: bookmark) { vm.openBookmark(bookmark) }
                    }
                case .asking(let query):
                    AskRow(query: query, answer: vm.answerText, isThinking: false) { vm.execute() }
                case .thinking(let query):
                    AskRow(query: query, answer: nil, isThinking: true) { }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.surfaceFill)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(theme.surfaceStroke, lineWidth: 1)
                }
                .padding(.horizontal, 16)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.filteredBookmarks.map(\.id))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.state)
    }
}
