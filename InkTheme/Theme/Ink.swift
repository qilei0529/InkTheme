import SwiftUI

enum Ink {
    static let buttonHeight: CGFloat = 44
    static let barButtonHeight: CGFloat = 32
    static let cornerRadius: CGFloat = 12
    static let sheetCornerRadius: CGFloat = 24
    static let sheetScreenInset: CGFloat = 20
    static let borderWidth: CGFloat = 2
    static let voiceSize: CGFloat = 72
    static let listCoverSize: CGFloat = 48
    static let toggleWidth: CGFloat = 52
    static let toggleHeight: CGFloat = 32
    static let toggleKnobSize: CGFloat = 20
    static let checkboxSize: CGFloat = 32
}

struct InkOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(palette.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, InkSpace.lg)
            .background(palette.paper)
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                    .strokeBorder(palette.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(palette.inverse.opacity(isEnabled ? 1 : 0.7))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, InkSpace.lg)
            .background(palette.accent.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct InkBarOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(palette.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(minHeight: Ink.barButtonHeight)
            .padding(.horizontal, InkSpace.md)
            .background(palette.paper)
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                    .strokeBorder(palette.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkBarFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(InkTextStyle.bodyStrong.font)
            .foregroundStyle(palette.inverse.opacity(isEnabled ? 1 : 0.7))
            .frame(minHeight: Ink.barButtonHeight)
            .padding(.horizontal, InkSpace.md)
            .background(palette.accent.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct InkBarIconOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(palette.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(width: Ink.barButtonHeight, height: Ink.barButtonHeight)
            .background(palette.paper)
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                    .strokeBorder(palette.ink.opacity(isEnabled ? 1 : 0.25), lineWidth: Ink.borderWidth)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

struct InkBarIconFillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(palette.inverse.opacity(isEnabled ? 1 : 0.7))
            .frame(width: Ink.barButtonHeight, height: Ink.barButtonHeight)
            .background(palette.accent.opacity(isEnabled ? 1 : 0.25))
            .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
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
        modifier(InkScreenModifier())
    }

    func inkStroke(enabled: Bool = true) -> some View {
        modifier(InkStrokeModifier(enabled: enabled))
    }
}

private struct InkScreenModifier: ViewModifier {
    @Environment(\.inkPalette) private var palette

    func body(content: Content) -> some View {
        content.background(palette.paper, ignoresSafeAreaEdges: .all)
    }
}

private struct InkStrokeModifier: ViewModifier {
    var enabled: Bool
    @Environment(\.inkPalette) private var palette

    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                .strokeBorder(palette.ink.opacity(enabled ? 1 : 0.2), lineWidth: Ink.borderWidth)
        }
    }
}
