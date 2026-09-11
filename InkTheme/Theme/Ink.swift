import SwiftUI

enum Ink {
    static let buttonHeight: CGFloat = 44
    static let barButtonHeight: CGFloat = 32
    static let cornerRadius: CGFloat = 12
    static let sheetCornerRadius: CGFloat = 24
    static let sheetScreenInset: CGFloat = 20
    /// Medium detent side inset — half of `sheetScreenInset`.
    static let sheetMediumHorizontalInset: CGFloat = 10
    /// Large detent side inset — half of `sheetMediumHorizontalInset`. Full lerps to 0.
    static let sheetLargeHorizontalInset: CGFloat = 5
    /// Large detent vertical inset — half of `sheetScreenInset`. Full lerps to 0.
    static let sheetLargeVerticalInset: CGFloat = 10
    /// Extra top padding inside full-bleed sheet, on top of the status-bar safe area.
    static let sheetFullTopExtra: CGFloat = 36
    static let sheetMediumFraction: CGFloat = 0.5
    /// Large detent height as a fraction of the full-screen frame (between medium and full).
    static let sheetLargeFraction: CGFloat = 0.88
    static let sheetMoveInOffset: CGFloat = 32
    static let dialogMaxWidth: CGFloat = 320
    static let dialogMoveInOffset: CGFloat = 40
    static let borderWidth: CGFloat = 2
    static let voiceSize: CGFloat = 72
    static let listCoverSize: CGFloat = 48
    static let toggleWidth: CGFloat = 52
    static let toggleHeight: CGFloat = 32
    static let toggleKnobSize: CGFloat = 20
    static let checkboxSize: CGFloat = 32
}

enum InkFieldSize: CaseIterable, Identifiable {
    case sm
    case md

    var id: Self { self }

    var height: CGFloat {
        switch self {
        case .sm: Ink.barButtonHeight
        case .md: Ink.buttonHeight
        }
    }

    var padding: CGFloat { InkSpace.md }

    /// `sm` uses footnote at full ink — not caption’s 0.55 opacity.
    var font: Font {
        switch self {
        case .sm: InkTextStyle.caption.font
        case .md: InkTextStyle.body.font
        }
    }
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

    func inkField(size: InkFieldSize = .md, enabled: Bool = true) -> some View {
        modifier(InkFieldModifier(size: size, enabled: enabled))
    }
}

private struct InkFieldModifier: ViewModifier {
    var size: InkFieldSize
    var enabled: Bool
    @Environment(\.inkPalette) private var palette

    func body(content: Content) -> some View {
        content
            .font(size.font)
            .foregroundStyle(palette.ink)
            .padding(.horizontal, size.padding)
            .frame(minHeight: size.height)
            .inkStroke(enabled: enabled)
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
    @Environment(\.inkRadius) private var inkRadius

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
        content
            .background(palette.paper)
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(palette.ink.opacity(enabled ? 1 : 0.2), lineWidth: Ink.borderWidth)
            }
    }
}
