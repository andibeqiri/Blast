import SwiftUI

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

    // MARK: Drag gesture

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

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .environment(\.theme, .midnight)
}
