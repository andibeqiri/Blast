import SwiftUI

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
        backgroundTop: Color(hue: 0.64, saturation: 0.25, brightness: 0.10),
        backgroundBottom: Color(hue: 0.64, saturation: 0.30, brightness: 0.05),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color.white.opacity(0.08),
        navigationAccent: Color(hue: 0.58, saturation: 0.7, brightness: 0.9),
        actionAccent: Color(hue: 0.54, saturation: 0.8, brightness: 0.95),
        askAccent: Color(hue: 0.78, saturation: 0.65, brightness: 0.88),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.55),
        tertiaryText: Color.white.opacity(0.3),
        barCornerRadius: 18,
        barHorizontalPadding: 16,
        destinationBackground: Color(hue: 0.64, saturation: 0.25, brightness: 0.08),
        loadBarColors: [Color(hue: 0.58, saturation: 0.7, brightness: 0.9), Color(hue: 0.78, saturation: 0.65, brightness: 0.88)]
    )

    /// Carbon — near-black with electric-green highlights
    static let carbon = Theme(
        backgroundTop: Color(white: 0.07),
        backgroundBottom: Color(white: 0.03),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color.white.opacity(0.06),
        navigationAccent: Color(hue: 0.38, saturation: 0.85, brightness: 0.72),
        actionAccent: Color(hue: 0.14, saturation: 0.9, brightness: 0.95),
        askAccent: Color(hue: 0.48, saturation: 0.75, brightness: 0.78),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.5),
        tertiaryText: Color.white.opacity(0.28),
        barCornerRadius: 14,
        barHorizontalPadding: 16,
        destinationBackground: Color(white: 0.06),
        loadBarColors: [Color(hue: 0.38, saturation: 0.85, brightness: 0.72), Color(hue: 0.48, saturation: 0.75, brightness: 0.78)]
    )

    /// Sunset — warm near-black with amber and rose accents
    static let sunset = Theme(
        backgroundTop: Color(hue: 0.06, saturation: 0.18, brightness: 0.11),
        backgroundBottom: Color(hue: 0.06, saturation: 0.22, brightness: 0.05),
        surfaceFill: .ultraThinMaterial,
        surfaceStroke: Color.white.opacity(0.07),
        navigationAccent: Color(hue: 0.08, saturation: 0.85, brightness: 0.95),
        actionAccent: Color(hue: 0.12, saturation: 0.9, brightness: 0.95),
        askAccent: Color(hue: 0.95, saturation: 0.65, brightness: 0.88),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.55),
        tertiaryText: Color.white.opacity(0.3),
        barCornerRadius: 20,
        barHorizontalPadding: 16,
        destinationBackground: Color(hue: 0.06, saturation: 0.18, brightness: 0.09),
        loadBarColors: [Color(hue: 0.08, saturation: 0.85, brightness: 0.95), Color(hue: 0.95, saturation: 0.65, brightness: 0.88)]
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
        case .midnight: return Color(hue: 0.78, saturation: 0.65, brightness: 0.88)
        case .carbon: return Color(hue: 0.38, saturation: 0.85, brightness: 0.72)
        case .sunset: return Color(hue: 0.08, saturation: 0.85, brightness: 0.95)
        }
    }
}
