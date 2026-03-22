import SwiftUI

// Shared appearance state
class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
}

enum GrainTheme {
    private static var isDark: Bool { AppearanceManager.shared.isDarkMode }

    // Adaptive colors
    static var bg: Color {
        isDark ? Color(red: 0.055, green: 0.055, blue: 0.055)
               : Color(red: 0.976, green: 0.973, blue: 0.965)
    }
    static var surface: Color {
        isDark ? Color(red: 0.094, green: 0.094, blue: 0.094)
               : Color(red: 0.949, green: 0.945, blue: 0.933)
    }
    static var border: Color {
        isDark ? Color(red: 0.149, green: 0.149, blue: 0.149)
               : Color(red: 0.878, green: 0.871, blue: 0.855)
    }
    static var textPrimary: Color {
        isDark ? Color(red: 0.91, green: 0.91, blue: 0.91)
               : Color(red: 0.118, green: 0.118, blue: 0.118)
    }
    static var textSecondary: Color {
        isDark ? Color(red: 0.376, green: 0.376, blue: 0.376)
               : Color(red: 0.533, green: 0.522, blue: 0.502)
    }
    static var accent: Color {
        isDark ? Color(red: 0.627, green: 0.627, blue: 0.627)
               : Color(red: 0.4, green: 0.392, blue: 0.376)
    }
    static var dateHeader: Color {
        isDark ? Color(red: 0.267, green: 0.267, blue: 0.267)
               : Color(red: 0.667, green: 0.655, blue: 0.635)
    }

    // Price trends (same in both modes)
    static let priceUp = Color(red: 0.753, green: 0.314, blue: 0.314)
    static let priceDown = Color(red: 0.314, green: 0.627, blue: 0.439)
    static let priceFlat = Color(red: 0.5, green: 0.5, blue: 0.5)

    // Typography
    static let mono = Font.system(.body, design: .monospaced)

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// Reusable modifier for grain-styled screens
struct GrainScreenModifier: ViewModifier {
    @ObservedObject private var appearance = AppearanceManager.shared

    func body(content: Content) -> some View {
        content
            .background(GrainTheme.bg)
            .scrollContentBackground(.hidden)
    }
}

extension View {
    func grainScreen() -> some View {
        modifier(GrainScreenModifier())
    }
}
