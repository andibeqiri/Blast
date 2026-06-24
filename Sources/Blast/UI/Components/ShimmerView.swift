import SwiftUI

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
