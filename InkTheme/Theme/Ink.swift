import SwiftUI

enum Ink {
    static let ink = Color.black
    static let paper = Color.white
    static let buttonHeight: CGFloat = 44
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 2
    static let voiceSize: CGFloat = 72

    static let displayFont = Font.system(size: 40, weight: .bold, design: .default)
    static let titleFont = Font.system(.title2, design: .default).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.footnote, design: .default)
}

struct InkOutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Ink.bodyFont.weight(.semibold))
            .foregroundStyle(Ink.ink.opacity(isEnabled ? 1 : 0.35))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, 16)
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
            .font(Ink.bodyFont.weight(.semibold))
            .foregroundStyle(Ink.paper.opacity(isEnabled ? 1 : 0.7))
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .padding(.horizontal, 16)
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

    func inkScreen() -> some View {
        background(Ink.paper.ignoresSafeArea())
    }

    func inkStroke(enabled: Bool = true) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                .stroke(Ink.ink.opacity(enabled ? 1 : 0.2), lineWidth: Ink.borderWidth)
        }
    }
}
