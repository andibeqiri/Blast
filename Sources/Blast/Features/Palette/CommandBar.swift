import SwiftUI

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
