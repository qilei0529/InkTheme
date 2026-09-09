import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var typewriterKey = 0
    @State private var typedDone = false
    @State private var showListSheet = false
    @State private var showFormSheet = false
    @State private var showConfirmSheet = false
    @State private var formName = "Alex"
    @Environment(InkAppearanceStore.self) private var appearanceStore
    @Environment(\.inkPalette) private var palette

    private let sampleEnglish = "Could you stay a bit later to finish the report?"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: InkSpace.section) {
                    intro
                    appearanceCatalog
                    typeCatalog
                    spaceCatalog
                    navCatalog
                    listCatalog
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
                        .fill(palette.ink)
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
            Text("Ink / paper")
                .inkText(.caption)
            Text("Named type styles and spacing. Light is black ink on white paper; dark inverts. Buttons are 44 tall with an ink stroke.")
                .inkText(.body)
        }
    }

    private var appearanceCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Appearance")
            Text("Lock Light or Dark, or follow the system.")
                .inkText(.body)
            HStack(spacing: InkSpace.md) {
                ForEach(InkAppearance.allCases) { option in
                    appearanceButton(option, selected: appearanceStore.appearance)
                }
            }
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
                            .fill(palette.ink)
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

    private var listCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("List")
            Text("Cover, title, caption, and a 32pt bar action. Rows use a 2pt ink hairline. Last row drops the border.")
                .inkText(.body)

            VStack(spacing: 0) {
                InkListRow(title: "Pat", description: "English · A1") {
                    InkListCover {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("Start") {}
                        .inkBarFillButton()
                }

                InkListRow(title: "Sam", description: "English · A1") {
                    InkListCover {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("More", systemImage: "ellipsis") {}
                        .inkBarIconOutlineButton()
                }

                InkListRow(
                    title: "Riley",
                    description: "English · A1",
                    showsBottomBorder: false
                ) {
                    InkListCover {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("Start") {}
                        .inkBarFillButton()
                }
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
            InkSheetList {
                ForEach(Array(tutorRows.enumerated()), id: \.element.name) { index, tutor in
                    InkListRow(
                        title: tutor.name,
                        description: tutor.detail,
                        showsBottomBorder: index < tutorRows.count - 1
                    ) {
                        InkListCover {
                            Image(systemName: tutor.symbol)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(palette.ink)
                        }
                    } action: {
                        Button("Start") {}
                            .inkBarFillButton()
                    }
                    .inkSheetListRow()
                }
            }
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

    private var tutorRows: [(name: String, detail: String, symbol: String)] {
        [
            ("Pat", "English · A1", "person.fill"),
            ("Sam", "English · A1", "person.fill"),
            ("Riley", "English · A1", "person.fill"),
        ]
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .inkText(.capital)
    }

    @ViewBuilder
    private func appearanceButton(_ option: InkAppearance, selected: InkAppearance) -> some View {
        if selected == option {
            Button(option.title) { appearanceStore.select(option) }
                .inkFillButton()
        } else {
            Button(option.title) { appearanceStore.select(option) }
                .inkOutlineButton()
        }
    }
}

#Preview {
    DesignSystemPlaygroundView()
        .environment(InkAppearanceStore())
        .inkAppearance(.system)
}
