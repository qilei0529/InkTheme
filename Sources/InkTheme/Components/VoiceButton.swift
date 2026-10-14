import SwiftUI

public struct VoiceButton: View {
    @Binding var isListening: Bool
    @Environment(\.inkPalette) private var palette

    public init(isListening: Binding<Bool>) {
        _isListening = isListening
    }

    public var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isListening.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isListening ? palette.accent : palette.paper)
                    .frame(width: Ink.voiceSize, height: Ink.voiceSize)
                    .overlay {
                        Circle()
                            .strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
                    }
                    .scaleEffect(isListening ? 1.06 : 1)

                Image(systemName: isListening ? "waveform" : "mic")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(isListening ? palette.inverse : palette.ink)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "Stop voice" : "Start voice")
        .sensoryFeedback(.impact(weight: .medium), trigger: isListening)
    }
}
