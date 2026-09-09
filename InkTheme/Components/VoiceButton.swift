import SwiftUI

struct VoiceButton: View {
    @Binding var isListening: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isListening.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isListening ? Ink.ink : Ink.paper)
                    .frame(width: Ink.voiceSize, height: Ink.voiceSize)
                    .overlay {
                        Circle()
                            .stroke(Ink.ink, lineWidth: Ink.borderWidth)
                    }
                    .scaleEffect(isListening ? 1.06 : 1)

                Image(systemName: isListening ? "waveform" : "mic")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(isListening ? Ink.paper : Ink.ink)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "Stop voice" : "Start voice")
        .sensoryFeedback(.impact(weight: .medium), trigger: isListening)
    }
}
