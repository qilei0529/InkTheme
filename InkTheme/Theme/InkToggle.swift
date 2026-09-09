import SwiftUI

struct InkToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        Button {
            let apply = { configuration.isOn.toggle() }
            if reduceMotion {
                apply()
            } else {
                withAnimation(.easeInOut(duration: 0.2), apply)
            }
        } label: {
            HStack(spacing: InkSpace.md) {
                configuration.label
                Spacer(minLength: 0)
                capsule(isOn: configuration.isOn)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.35)
        .sensoryFeedback(.selection, trigger: configuration.isOn)
    }

    private func capsule(isOn: Bool) -> some View {
        HStack {
            if isOn {
                Spacer(minLength: 0)
            }
            Circle()
                .fill(isOn ? palette.inverse : palette.ink)
                .frame(width: Ink.toggleKnobSize, height: Ink.toggleKnobSize)
            if !isOn {
                Spacer(minLength: 0)
            }
        }
        .padding(4)
        .frame(width: Ink.toggleWidth, height: Ink.toggleHeight)
        .background(isOn ? palette.accent : palette.paper, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
                .opacity(isOn ? 0 : 1)
        }
        .accessibilityHidden(true)
    }
}

extension ToggleStyle where Self == InkToggleStyle {
    static var ink: InkToggleStyle { InkToggleStyle() }
}
