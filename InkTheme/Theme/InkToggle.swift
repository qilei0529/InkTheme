import SwiftUI

struct InkToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
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
        let knob = isOn ? Ink.toggleKnobSize + 2 : Ink.toggleKnobSize
        let inset = (Ink.toggleHeight - knob) / 2
        return ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule(style: .continuous)
                .fill(isOn ? palette.accent : palette.paper)
            Circle()
                .fill(isOn ? palette.inverse : palette.ink)
                .frame(width: knob, height: knob)
                .padding(inset)
        }
        .frame(width: Ink.toggleWidth, height: Ink.toggleHeight)
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
                .opacity(isOn ? 0 : 1)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.23), value: isOn)
        .accessibilityHidden(true)
    }
}

extension ToggleStyle where Self == InkToggleStyle {
    static var ink: InkToggleStyle { InkToggleStyle() }
}
