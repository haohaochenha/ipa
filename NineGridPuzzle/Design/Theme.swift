import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

enum Theme {
    static let rose = Color(hex: 0xF472B6)
    static let pink = Color(hex: 0xEC4899)
    static let purple = Color(hex: 0x8B5CF6)
    static let lilac = Color(hex: 0xA78BFA)
    static let gold = Color(hex: 0xF59E0B)
    static let ink = Color(hex: 0x141B2D)
    static let subInk = Color(hex: 0x5B6478)

    static var brand: LinearGradient {
        LinearGradient(colors: [rose, purple],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    static var goldGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0xFBBF24), Color(hex: 0xF97316)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    static var cardStroke: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.35)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

enum Formats {
    static func clock(_ seconds: Double) -> String {
        let total = max(0, Int(seconds.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    static func recordTime(_ seconds: Double) -> String {
        seconds > 0 ? clock(seconds) : "--:--"
    }
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

struct AuroraBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xFDF2F8),
                                    Color(hex: 0xF4F1FF),
                                    Color(hex: 0xEDF4FF)],
                           startPoint: .top,
                           endPoint: .bottom)

            Circle()
                .fill(Theme.rose.opacity(0.30))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -150, y: -310)

            Circle()
                .fill(Theme.lilac.opacity(0.32))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 170, y: -180)

            Circle()
                .fill(Theme.gold.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: -130, y: 330)
        }
        .ignoresSafeArea()
    }
}

struct GlassSurface: ViewModifier {
    var radius: CGFloat = 26

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .background(shape.fill(Color.white.opacity(0.40)))
            .background(shape.fill(Material.ultraThinMaterial))
            .overlay(shape.strokeBorder(Theme.cardStroke, lineWidth: 1))
            .clipShape(shape)
            .shadow(color: Theme.purple.opacity(0.14), radius: 22, x: 0, y: 14)
    }
}

extension View {
    func glass(radius: CGFloat = 26) -> some View {
        modifier(GlassSurface(radius: radius))
    }
}
