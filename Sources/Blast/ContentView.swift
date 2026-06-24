import SwiftUI

// MARK: - Root

struct ContentView: View {
    @State private var vm = PaletteViewModel()
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var screenHeight: CGFloat = 852
    @State private var selectedPreset: ThemePreset = .midnight
    @Environment(\.theme) private var theme

    var body: some View {
        ZStack(alignment: .bottom) {
            background

            // Idle home fills the screen when nothing is typed
            if vm.state == .idle {
                IdleHomeView(vm: vm)
                    .transition(.opacity)
                    .zIndex(1)
            }

            if vm.state != .dismissed && vm.state != .dismissing {
                palettePanel
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(2)
            }
            if let msg = vm.toastMessage {
                ToastView(message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
            // Theme switcher — top right
            ThemePicker(selected: $selectedPreset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 56)
                .padding(.trailing, 16)
                .zIndex(5)
        }
        .ignoresSafeArea(.container)
        .environment(\.theme, selectedPreset.value)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { screenHeight = $0 }
        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: vm.state)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.toastMessage)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedPreset)
        .onAppear {
            // Let the first frame render in .dismissed state so SwiftUI has
            // a baseline; then animate everything in.
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(60))
                vm.present()
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: vm.isAsking)
        .sensoryFeedback(.selection, trigger: selectedPreset)
        .fullScreenCover(item: Bindable(vm).destination) { dest in
            DestinationView(destination: dest, theme: selectedPreset.value) {
                vm.destination = nil
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: Background

    private var background: some View {
        // Only fade during the initial launch (.dismissed), not during drag-to-dismiss
        let isDismissed = vm.state == .dismissed
        return LinearGradient(
            colors: [theme.backgroundTop, theme.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .opacity(isDismissed ? 0 : 1)
        .onTapGesture { vm.dismiss() }
        .animation(.easeIn(duration: 0.18), value: isDismissed)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedPreset)
    }

    // MARK: Palette panel

    private var palettePanel: some View {
        VStack(spacing: 0) {
            if hasResults {
                ResultsList(vm: vm)
                    .frame(maxHeight: 340)
            }
            CommandBar(vm: vm, dragOffset: $dragOffset, isDragging: $isDragging)
        }
        .offset(y: rubberBand(dragOffset))
        .gesture(dismissGesture)
        .padding(.bottom, 8)
    }

    private var hasResults: Bool {
        switch vm.state {
        case .filtering: return !vm.filteredBookmarks.isEmpty
        case .action: return vm.activeAction != nil
        case .asking, .thinking: return true
        default: return false
        }
    }

    // MARK: Drag gesture with velocity

    private var dismissGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                isDragging = true
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                isDragging = false
                let velocity = value.predictedEndTranslation.height - value.translation.height
                let distance = value.translation.height
                let fastFlick = velocity > 300 && distance > screenHeight * 0.25
                let slowDrag = distance > screenHeight * 0.55

                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    dragOffset = 0
                }
                if fastFlick || slowDrag {
                    vm.dismiss()
                }
            }
    }

    private func rubberBand(_ offset: CGFloat) -> CGFloat {
        guard offset > 0 else { return offset }
        return offset * 0.4
    }
}

// MARK: - Theme picker

struct ThemePicker: View {
    @Binding var selected: ThemePreset
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                Circle()
                    .fill(selected.preview)
                    .frame(width: 24, height: 24)
                    .overlay { Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1) }
            }

            if isExpanded {
                VStack(alignment: .trailing, spacing: 6) {
                    ForEach(ThemePreset.allCases) { preset in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selected = preset
                                isExpanded = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(preset.rawValue)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(selected == preset ? 1 : 0.6))
                                Circle()
                                    .fill(preset.preview)
                                    .frame(width: 18, height: 18)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Command bar

struct CommandBar: View {
    @Bindable var vm: PaletteViewModel
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    @FocusState private var isFocused: Bool
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: modeIcon)
                .foregroundStyle(modeAccent)
                .frame(width: 20)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: modeAccent)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: modeIcon)

            TextField(vm.hintText, text: $vm.inputText)
                .focused($isFocused)
                .submitLabel(.go)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { vm.execute() }
                .foregroundStyle(theme.primaryText)
                .tint(modeAccent)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: vm.hintText)

            if !vm.inputText.isEmpty {
                Button {
                    vm.inputText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.secondaryText)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: theme.barCornerRadius, style: .continuous)
                .fill(theme.surfaceFill)
                .overlay {
                    RoundedRectangle(cornerRadius: theme.barCornerRadius, style: .continuous)
                        .strokeBorder(modeAccent.opacity(0.4), lineWidth: 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: modeAccent)
                }
        }
        .padding(.horizontal, theme.barHorizontalPadding)
        .onAppear { isFocused = true }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.inputText.isEmpty)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: theme.barCornerRadius)
    }

    private var modeIcon: String {
        switch vm.state {
        case .asking, .thinking: return "sparkles"
        case .action: return "arrow.up.right"
        default: return "magnifyingglass"
        }
    }

    private var modeAccent: Color {
        switch vm.state {
        case .asking, .thinking: return theme.askAccent
        case .action: return theme.actionAccent
        default: return theme.navigationAccent
        }
    }
}

// MARK: - Results list

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

// MARK: - Row types

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

// MARK: - Shimmer

struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    @Environment(\.theme) private var theme

    var body: some View {
        GeometryReader { geo in
            let gradient = LinearGradient(
                stops: [
                    .init(color: theme.askAccent.opacity(0.05), location: phase - 0.3),
                    .init(color: theme.askAccent.opacity(0.2), location: phase),
                    .init(color: theme.askAccent.opacity(0.05), location: phase + 0.3),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            Rectangle()
                .fill(gradient)
                .frame(width: geo.size.width)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                phase = 1.3
            }
        }
    }
}

// MARK: - Toast

struct ToastView: View {
    let message: String
    @Environment(\.theme) private var theme

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(theme.primaryText)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .fill(theme.surfaceFill)
                    .overlay {
                        Capsule().strokeBorder(theme.surfaceStroke, lineWidth: 1)
                    }
            }
            .padding(.top, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .environment(\.theme, .midnight)
}
