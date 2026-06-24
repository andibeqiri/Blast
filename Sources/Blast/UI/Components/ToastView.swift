import SwiftUI

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
