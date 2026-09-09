import SwiftUI

enum Ink {
    static let ink = Color.black
    static let paper = Color.white
    static let buttonHeight: CGFloat = 44
    static let barButtonHeight: CGFloat = 32
    static let cornerRadius: CGFloat = 12
    static let sheetCornerRadius: CGFloat = 24
    static let sheetScreenInset: CGFloat = 20
    static let borderWidth: CGFloat = 2
    static let voiceSize: CGFloat = 72
    static let listCoverSize: CGFloat = 48
}

struct InkOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(Ink.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, InkSpace.lg)
            .background(Ink.paper)
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                    .stroke(Ink.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(Ink.paper.opacity(isEnabled ? 1 : 0.7))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, InkSpace.lg)
            .background(Ink.ink.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct InkBarOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(Ink.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(minHeight: Ink.barButtonHeight)
            .padding(.horizontal, InkSpace.md)
            .background(Ink.paper)
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                    .stroke(Ink.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkBarFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(Ink.paper.opacity(isEnabled ? 1 : 0.7))
            .frame(minHeight: Ink.barButtonHeight)
            .padding(.horizontal, InkSpace.md)
            .background(Ink.ink.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct InkBarIconOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Ink.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(width: Ink.barButtonHeight, height: Ink.barButtonHeight)
            .background(Ink.paper)
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                    .stroke(Ink.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkBarIconFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Ink.paper.opacity(isEnabled ? 1 : 0.7))
            .frame(width: Ink.barButtonHeight, height: Ink.barButtonHeight)
            .background(Ink.ink.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension View {
    func inkOutlineButton() -> some View {
        buttonStyle(InkOutlineButtonStyle())
    }

    func inkFillButton() -> some View {
        buttonStyle(InkFillButtonStyle())
    }

    func inkBarOutlineButton() -> some View {
        buttonStyle(InkBarOutlineButtonStyle())
    }

    func inkBarFillButton() -> some View {
        buttonStyle(InkBarFillButtonStyle())
    }

    func inkBarIconOutlineButton() -> some View {
        buttonStyle(InkBarIconOutlineButtonStyle())
    }

    func inkBarIconFillButton() -> some View {
        buttonStyle(InkBarIconFillButtonStyle())
    }

    func inkScreen() -> some View {
        background(Ink.paper.ignoresSafeArea())
    }

    func inkStroke(enabled: Bool = true) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                .strokeBorder(Ink.ink.opacity(enabled ? 1 : 0.2), lineWidth: Ink.borderWidth)
        }
    }
}
