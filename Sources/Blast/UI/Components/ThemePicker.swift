import SwiftUI

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
