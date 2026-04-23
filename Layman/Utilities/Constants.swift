import SwiftUI

// MARK: - Adaptive Colors (Light + Dark mode)

extension Color {
    // Accent — same in both modes
    nonisolated static let primaryOrange = Color(hex: "E8734A")
    nonisolated static let gradientStart = Color(hex: "F5C6A0")
    nonisolated static let gradientEnd = Color(hex: "E8734A")
    nonisolated static let tabActive = Color(hex: "E8734A")
    nonisolated static let tabInactive = Color(hex: "ADADAD")
    nonisolated static let chatUserBubble = Color(hex: "E8734A")
    nonisolated static let suggestionChip = Color(hex: "FFF0E6")

    // Adaptive colors — use UIColor for automatic light/dark
    nonisolated static let appBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "1A1A1A")) : UIColor(Color(hex: "FFF8F2"))
    })

    nonisolated static let cardBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "2C2C2E")) : UIColor(Color(hex: "FFF0E6"))
    })

    nonisolated static let textPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : UIColor(Color(hex: "1A1A1A"))
    })

    nonisolated static let textSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(white: 0.65, alpha: 1) : UIColor(Color(hex: "6B6B6B"))
    })

    nonisolated static let chatBotBubble = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "2C2C2E")) : UIColor(Color(hex: "F5F5F5"))
    })

    nonisolated static let cardWhite = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "2C2C2E")) : .white
    })

    nonisolated static let searchBarBg = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(Color(hex: "3A3A3C")) : UIColor(Color(hex: "FFF0E6"))
    })
}

extension Color {
    nonisolated init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

nonisolated enum AppConstants {
    static let cornerRadiusCard: CGFloat = 16
    static let cornerRadiusThumbnail: CGFloat = 12
    static let cornerRadiusButton: CGFloat = 25
    static let standardPadding: CGFloat = 16
    static let thumbnailSize: CGFloat = 60
    static let carouselHeight: CGFloat = 220
}

// UI polish

// UI polish

// Refactoring
