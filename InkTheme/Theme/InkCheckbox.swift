import SwiftUI

struct InkCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.78))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.88, y: rect.minY + rect.height * 0.22))
        return path
    }
}

struct InkCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        InkCheckboxBody(configuration: configuration)
    }
}

private struct InkCheckboxBody: View {
    let configuration: ToggleStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.inkPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hookPulse = 0

    var body: some View {
        Button {
            let apply = { configuration.isOn.toggle() }
            if reduceMotion {
                apply()
            } else {
                hookPulse += 1
                withAnimation(.easeInOut(duration: 0.2), apply)
            }
        } label: {
            HStack(spacing: InkSpace.md) {
                box
                configuration.label
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.35)
        .sensoryFeedback(.selection, trigger: configuration.isOn)
    }

    private var box: some View {
        let isOn = configuration.isOn
        return RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
            .fill(isOn ? palette.accent : palette.ink.opacity(0.06))
            .frame(width: Ink.checkboxSize, height: Ink.checkboxSize)
            .overlay {
                InkCheckmarkShape()
                    .stroke(palette.inverse, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                    .padding(7)
                    .keyframeAnimator(initialValue: 1.0, trigger: hookPulse) { content, scale in
                        content.scaleEffect(scale)
                    } keyframes: { _ in
                        CubicKeyframe(1.28, duration: 0.1)
                        CubicKeyframe(1.0, duration: 0.16)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous)
                    .stroke(palette.ink, lineWidth: Ink.borderWidth)
                    .opacity(isOn ? 0 : 1)
            }
            .accessibilityHidden(true)
    }
}

extension ToggleStyle where Self == InkCheckboxStyle {
    static var inkCheckbox: InkCheckboxStyle { InkCheckboxStyle() }
}
