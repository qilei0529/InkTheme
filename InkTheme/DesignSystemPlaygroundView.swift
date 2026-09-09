import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var typewriterKey = 0
    @State private var typedDone = false

    private let sampleEnglish = "Could you stay a bit later to finish the report?"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    intro
                    typeScale
                    typingDemo
                    buttons
                    voice
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .inkScreen()
            .navigationTitle("Ink")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Black / white")
                .font(Ink.captionFont)
                .foregroundStyle(Ink.ink.opacity(0.55))
            Text("Apple system font. Buttons are 44 tall with a black stroke and rounded corners.")
                .font(Ink.bodyFont)
                .foregroundStyle(Ink.ink)
        }
    }

    private var typeScale: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("English, large")
            Text("INK")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(Ink.ink)
                .tracking(4)
            Text("A colleague asks if you can stay late.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Ink.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var typingDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Typing")
            TypewriterText(
                text: sampleEnglish,
                font: .system(size: 28, weight: .bold),
                onFinished: { typedDone = true }
            )
            .id(typewriterKey)

            Button("Replay typing") {
                typedDone = false
                typewriterKey += 1
            }
            .inkOutlineButton()

            if typedDone {
                Text("Done.")
                    .font(Ink.captionFont)
                    .foregroundStyle(Ink.ink.opacity(0.55))
            }
        }
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Black-border buttons")
            Button("Next item") {}
                .inkFillButton()
            Button("Show grammar hint") {}
                .inkOutlineButton()
            HStack(spacing: 12) {
                Button("Yes") {}
                    .inkFillButton()
                Button("No") {}
                    .inkOutlineButton()
            }
        }
    }

    private var voice: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Voice")
            HStack(spacing: 20) {
                VoiceButton(isListening: $isListening)
                VStack(alignment: .leading, spacing: 8) {
                    SoundWaveView(isActive: isListening)
                    Text(isListening ? "Listening…" : "Tap the mic.")
                        .font(Ink.captionFont)
                        .foregroundStyle(Ink.ink.opacity(0.55))
                }
            }

            Button(isListening ? "Stop" : "Start listening") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isListening.toggle()
                }
            }
            .inkOutlineButton()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(Ink.captionFont.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(Ink.ink.opacity(0.45))
    }
}

#Preview {
    DesignSystemPlaygroundView()
}
