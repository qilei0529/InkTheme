import SwiftUI

struct InkToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
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
        let knob = Ink.toggleKnobSize
        let inset = (Ink.toggleHeight - knob) / 2
        let radius = inkRadius.toggle
        let track = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return ZStack(alignment: isOn ? .trailing : .leading) {
            track
                .fill(isOn ? palette.accent : palette.paper)
            RoundedRectangle(cornerRadius: inkRadius.toggleKnob, style: .continuous)
                .fill(isOn ? palette.inverse : palette.ink)
                .frame(width: knob, height: knob)
                .padding(inset)
        }
        .frame(width: Ink.toggleWidth, height: Ink.toggleHeight)
        .overlay {
            track
                .strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.23), value: isOn)
        .accessibilityHidden(true)
    }
}

extension ToggleStyle where Self == InkToggleStyle {
    static var ink: InkToggleStyle { InkToggleStyle() }
}
