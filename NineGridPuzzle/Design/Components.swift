import SwiftUI

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String = "play.fill"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(Theme.rounded(18, .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Capsule().fill(Theme.brand))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 1))
            .shadow(color: Theme.pink.opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(PressableStyle())
    }
}

struct GlassIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundColor(Theme.ink)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.white.opacity(0.55)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.85), lineWidth: 1))
                .shadow(color: Theme.purple.opacity(0.16), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressableStyle())
    }
}

struct GhostButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(Theme.rounded(15, .semibold))
            }
            .foregroundColor(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Capsule().fill(Color.white.opacity(0.55)))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.85), lineWidth: 1))
            .shadow(color: Theme.purple.opacity(0.12), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressableStyle())
    }
}

struct StatPill: View {
    let title: String
    let value: String
    var highlight: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.rounded(18, .bold))
                .foregroundColor(highlight ? Theme.pink : Theme.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(Theme.rounded(11, .medium))
                .foregroundColor(Theme.subInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glass(radius: 18)
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.rounded(14, .semibold))
            .foregroundColor(Theme.subInk)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.pink)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Theme.pink.opacity(0.12)))

            Text(title)
                .font(Theme.rounded(14, .medium))
                .foregroundColor(Theme.ink)

            Spacer(minLength: 4)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Theme.pink))
                .scaleEffect(0.85)
        }
    }
}
