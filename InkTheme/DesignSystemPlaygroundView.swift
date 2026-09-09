import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var typewriterKey = 0
    @State private var typedDone = false

    private let sampleEnglish = "Could you stay a bit later to finish the report?"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: InkSpace.section) {
                    intro
                    typeCatalog
                    spaceCatalog
                    typingDemo
                    buttons
                    voice
                }
                .padding(InkSpace.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .inkScreen()
            .navigationTitle("Ink")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: InkSpace.sm) {
            Text("Black / white")
                .inkText(.caption)
            Text("Named type styles and spacing. Buttons are 44 tall with a black stroke.")
                .inkText(.body)
        }
    }

    private var typeCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Type")
            ForEach(InkTextStyle.allCases) { style in
                VStack(alignment: .leading, spacing: InkSpace.xs) {
                    Text(style.sample)
                        .inkText(style)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(style.spec)
                        .inkText(.caption)
                }
            }
        }
    }

    private var spaceCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Space")
            Text("Label to body uses xs or sm. Sections use section. Screen inset is xl.")
                .inkText(.body)
            ForEach(InkSpaceToken.allCases) { token in
                VStack(alignment: .leading, spacing: InkSpace.xxs) {
                    HStack(alignment: .center, spacing: InkSpace.sm) {
                        Rectangle()
                            .fill(Ink.ink)
                            .frame(width: token.value, height: InkSpace.md)
                        Text("\(token.rawValue)  \(Int(token.value))")
                            .inkText(.bodyStrong)
                    }
                    Text(token.usage)
                        .inkText(.caption)
                }
            }
        }
    }

    private var typingDemo: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Typing")
            TypewriterText(text: sampleEnglish, onFinished: { typedDone = true })
                .id(typewriterKey)

            Button("Replay typing") {
                typedDone = false
                typewriterKey += 1
            }
            .inkOutlineButton()

            if typedDone {
                Text("Done.")
                    .inkText(.caption)
            }
        }
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Black-border buttons")
            Button("Next item") {}
                .inkFillButton()
            Button("Show grammar hint") {}
                .inkOutlineButton()
            HStack(spacing: InkSpace.md) {
                Button("Yes") {}
                    .inkFillButton()
                Button("No") {}
                    .inkOutlineButton()
            }
        }
    }

    private var voice: some View {
        VStack(alignment: .leading, spacing: InkSpace.lg) {
            sectionTitle("Voice")
            HStack(spacing: InkSpace.xl) {
                VoiceButton(isListening: $isListening)
                VStack(alignment: .leading, spacing: InkSpace.xs) {
                    SoundWaveView(isActive: isListening)
                    Text(isListening ? "Listening…" : "Tap the mic.")
                        .inkText(.caption)
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
            .inkText(.capital)
    }
}

#Preview {
    DesignSystemPlaygroundView()
}
