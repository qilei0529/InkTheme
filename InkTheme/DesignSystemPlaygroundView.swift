import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var typewriterKey = 0
    @State private var typedDone = false
    @State private var showListSheet = false
    @State private var showFormSheet = false
    @State private var showConfirmSheet = false
    @State private var formName = "Alex"

    private let sampleEnglish = "Could you stay a bit later to finish the report?"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: InkSpace.section) {
                    intro
                    typeCatalog
                    spaceCatalog
                    navCatalog
                    sheetCatalog
                    typingDemo
                    buttons
                    voice
                }
                .padding(InkSpace.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .inkScreen()
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                InkNavBar(title: "Ink") {
                    Button("Close") {}
                        .inkBarOutlineButton()
                    Button("Add", systemImage: "plus") {}
                        .inkBarIconFillButton()
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Ink.ink)
                        .frame(height: Ink.borderWidth)
                }
            }
            .sheet(isPresented: $showListSheet) {
                listSheet
            }
            .sheet(isPresented: $showFormSheet) {
                formSheet
            }
            .sheet(isPresented: $showConfirmSheet) {
                confirmSheet
            }
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

    private var navCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Nav")
            Text("Hero title at 28. Text actions hug at 32; icon actions are a 32 square. Page actions stay 44 and full width.")
                .inkText(.body)
            HStack(spacing: InkSpace.sm) {
                Button("Close") {}
                    .inkBarOutlineButton()
                Button("Add", systemImage: "plus") {}
                    .inkBarIconFillButton()
                Button("History", systemImage: "list.bullet") {}
                    .inkBarIconOutlineButton()
            }
        }
    }

    private var sheetCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Sheet")
            Text("Opaque paper sheets — no iOS 26 glass. Medium confirm sits 20pt above the screen bottom. Close is a square xmark.")
                .inkText(.body)
            Button("List sheet") { showListSheet = true }
                .inkOutlineButton()
            Button("Form sheet") { showFormSheet = true }
                .inkOutlineButton()
            Button("Confirm sheet") { showConfirmSheet = true }
                .inkFillButton()
        }
    }

    private var listSheet: some View {
        InkSheet(title: "Tutors") {
            InkSheetCloseButton { showListSheet = false }
            Button("Add", systemImage: "plus") {}
                .inkBarIconFillButton()
        } content: {
            List {
                ForEach(
                    [
                        ("Pat", "English · A1"),
                        ("Sam", "English · A1"),
                        ("Riley", "English · A1"),
                    ],
                    id: \.0
                ) { name, detail in
                    VStack(alignment: .leading, spacing: InkSpace.xxs) {
                        Text(name)
                            .inkText(.bodyStrong)
                        Text(detail)
                            .inkText(.caption)
                    }
                    .listRowBackground(Ink.paper)
                    .listRowSeparatorTint(Ink.ink.opacity(0.12))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var formSheet: some View {
        InkSheet(title: "Edit") {
            InkSheetCloseButton { showFormSheet = false }
        } footer: {
            InkSheetFooter {
                Button("Save") { showFormSheet = false }
                    .inkFillButton()
            }
        } content: {
            InkSheetBody {
                VStack(alignment: .leading, spacing: InkSpace.xs) {
                    Text("NAME")
                        .inkText(.capital)
                    TextField("Name", text: $formName)
                        .inkText(.body)
                        .padding(InkSpace.md)
                        .inkStroke()
                }
                Text("Fields sit on paper with a 2pt stroke. Footer holds the full-width 44pt fill action.")
                    .inkText(.caption)
            }
        }
    }

    private var confirmSheet: some View {
        InkSheet(title: "Leave", detent: .medium) {
            InkSheetCloseButton { showConfirmSheet = false }
        } footer: {
            InkSheetFooter(showsHairline: false) {
                Button("Continue") { showConfirmSheet = false }
                    .inkFillButton()
                Button("Cancel") { showConfirmSheet = false }
                    .inkOutlineButton()
            }
        } content: {
            VStack(alignment: .leading, spacing: InkSpace.sm) {
                Text("DRAFT")
                    .inkText(.capital)
                Text("Discard this draft? You can start a new one anytime.")
                    .inkText(.body)
            }
            .padding(InkSpace.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
