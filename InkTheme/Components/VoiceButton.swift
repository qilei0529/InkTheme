import SwiftUI

struct VoiceButton: View {
    @Binding var isListening: Bool
    @Environment(\.inkPalette) private var palette

    var body: some View {
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
                            .stroke(palette.ink, lineWidth: Ink.borderWidth)
                    }
                    .scaleEffect(isListening ? 1.06 : 1)

                Image(systemName: isListening ? "waveform" : "mic")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(isListening ? palette.paper : palette.ink)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "Stop voice" : "Start voice")
        .sensoryFeedback(.impact(weight: .medium), trigger: isListening)
    }
}
