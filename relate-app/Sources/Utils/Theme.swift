import SwiftUI

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Duo Design System (Dark Mode computed properties)

extension Color {
    // Brand colors
    static var duoGreen: Color { Color(hex: "#58cc02") }
    static var duoGreenDark: Color { Color(hex: "#46a302") }
    static var duoGreenTint: Color { Color(hex: "#d7ffb8") }
    
    static var duoBlue: Color { Color(hex: "#1cb0f6") }
    static var duoBlueDark: Color { Color(hex: "#1899d6") }
    static var duoBlueTint: Color { Color(hex: "#dcfce7") }
    
    static var duoYellow: Color { Color(hex: "#ffc800") }
    static var duoYellowDark: Color { Color(hex: "#e5b400") }
    
    static var duoRed: Color { Color(hex: "#ff4b4b") }
    static var duoRedDark: Color { Color(hex: "#cc3c3c") }
    
    // Adaptive semantic colors
    static var duoText: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#dceaea")) : UIColor(Color(hex: "#4b4b4b")) }) }
    static var duoTextMuted: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#77858c")) : UIColor(Color(hex: "#afafaf")) }) }
    
    static var duoBg: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#131f24")) : UIColor.white }) }
    static var duoSurface: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#202f36")) : UIColor.white }) }
    static var duoSurfaceSecondary: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#202f36")) : UIColor(Color(hex: "#f7f7f7")) }) }
    
    static var duoBorder: Color { Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(Color(hex: "#37464f")) : UIColor(Color(hex: "#e5e5e5")) }) }
}

// MARK: - Milestone Type Colors

extension MilestoneType {
    var bgColor: Color {
        switch self {
        case .birthday: return .duoYellow
        case .anniversary: return .duoRed
        case .milestone: return .duoBlue
        }
    }
    
    var textColor: Color {
        switch self {
        case .birthday: return .duoYellow
        case .anniversary: return .duoRed
        case .milestone: return .duoBlue
        }
    }
}
