import SwiftUI

// MARK: - Hex color convenience

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Theme

struct Theme {
    // Surface & background
    var backgroundTop: Color
    var backgroundBottom: Color
    var surfaceFill: Material
    var surfaceStroke: Color

    // Accent colors per mode
    var navigationAccent: Color   // filtering / bookmark mode
    var actionAccent: Color       // keyword action mode
    var askAccent: Color          // ask / thinking mode

    // Text
    var primaryText: Color
    var secondaryText: Color
    var tertiaryText: Color

    // Bar
    var barCornerRadius: CGFloat
    var barHorizontalPadding: CGFloat

    // Destination chrome
    var destinationBackground: Color
    var loadBarColors: [Color]
}

// MARK: - Built-in presets

extension Theme {
    /// Deep space — dark navy with violet asks
    static let midnight = Theme(
        backgroundTop: Color(hex: "#13141A"),
        backgroundBottom: Color(hex: "#09090D"),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color(hex: "#FFFFFF14"),
        navigationAccent: Color(hex: "#4598E6"),
        actionAccent: Color(hex: "#30C4F2"),
        askAccent: Color(hex: "#B24FE0"),
        primaryText: .white,
        secondaryText: Color(hex: "#FFFFFF8C"),
        tertiaryText: Color(hex: "#FFFFFF4D"),
        barCornerRadius: 18,
        barHorizontalPadding: 16,
        destinationBackground: Color(hex: "#0F1014"),
        loadBarColors: [Color(hex: "#4598E6"), Color(hex: "#B24FE0")]
    )

    /// Carbon — near-black with electric-green highlights
    static let carbon = Theme(
        backgroundTop: Color(hex: "#121212"),
        backgroundBottom: Color(hex: "#080808"),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color(hex: "#FFFFFF0F"),
        navigationAccent: Color(hex: "#1CB847"),
        actionAccent: Color(hex: "#F2CF18"),
        askAccent: Color(hex: "#32C7B5"),
        primaryText: .white,
        secondaryText: Color(hex: "#FFFFFF80"),
        tertiaryText: Color(hex: "#FFFFFF47"),
        barCornerRadius: 14,
        barHorizontalPadding: 16,
        destinationBackground: Color(hex: "#0F0F0F"),
        loadBarColors: [Color(hex: "#1CB847"), Color(hex: "#32C7B5")]
    )

    /// Sunset — warm near-black with amber and rose accents
    static let sunset = Theme(
        backgroundTop: Color(hex: "#1C1917"),
        backgroundBottom: Color(hex: "#0D0B0A"),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color(hex: "#FFFFFF12"),
        navigationAccent: Color(hex: "#F28724"),
        actionAccent: Color(hex: "#F2B518"),
        askAccent: Color(hex: "#E04F7A"),
        primaryText: .white,
        secondaryText: Color(hex: "#FFFFFF8C"),
        tertiaryText: Color(hex: "#FFFFFF4D"),
        barCornerRadius: 20,
        barHorizontalPadding: 16,
        destinationBackground: Color(hex: "#171413"),
        loadBarColors: [Color(hex: "#F28724"), Color(hex: "#E04F7A")]
    )
}

// MARK: - Environment injection

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .midnight
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Preset list (for ThemePicker)

enum ThemePreset: String, CaseIterable, Identifiable {
    case midnight = "Midnight"
    case carbon = "Carbon"
    case sunset = "Sunset"

    var id: String { rawValue }

    var value: Theme {
        switch self {
        case .midnight: return .midnight
        case .carbon: return .carbon
        case .sunset: return .sunset
        }
    }

    var preview: Color {
        switch self {
        case .midnight: return Color(hex: "#B24FE0")
        case .carbon: return Color(hex: "#1CB847")
        case .sunset: return Color(hex: "#F28724")
        }
    }
}
