import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var toggleOn = true
    @State private var toggleOff = false
    @State private var toggleDisabled = true
    @State private var checkboxOn = true
    @State private var checkboxOff = false
    @State private var checkboxDisabled = true
    @State private var showListSheet = false
    @State private var showFormSheet = false
    @State private var showConfirmSheet = false
    @State private var showAlertDialog = false
    @State private var showCustomDialog = false
    @State private var dialogName = "Alex"
    @State private var formName = "Alex"
    @State private var fieldText = "Could you stay a bit later?"
    @State private var fieldSearch = "Search"
    @State private var fieldDisabled = "Disabled field"
    @Environment(InkAppearanceStore.self) private var appearanceStore
    @Environment(\.inkPalette) private var palette

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: InkSpace.section) {
                    intro
                    appearanceCatalog
                    accentCatalog
                    paperCatalog
                    radiusCatalog
                    typeCatalog
                    spaceCatalog
                    navCatalog
                    listCatalog
                    fieldCatalog
                    sheetCatalog
                    dialogCatalog
                    buttons
                    toggles
                    checkboxes
                    voice
                }
                .padding(InkSpace.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .inkScreen()
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                InkNavBar(title: "Ink") {
                    Button("Settings") {}
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
            .inkSheet(isPresented: $showListSheet) {
                listSheet
            }
            .inkSheet(isPresented: $showFormSheet) {
                formSheet
            }
            .inkSheet(isPresented: $showConfirmSheet, detent: .mediumAndFull) {
                confirmSheet
            }
            .inkAlert(
                isPresented: $showAlertDialog,
                title: "Delete",
                message: "This cannot be undone.",
                primary: "Delete",
                secondary: "Cancel"
            ) {
            }
            .inkDialog(isPresented: $showCustomDialog) {
                customDialog
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: InkSpace.sm) {
            Text("INK / PAPER")
                .inkText(.caption)
            Text("Named type styles and spacing. Light is black ink on white paper; dark inverts. Fill uses accent. Dark paper can be black or a deep hue — Light stays white.")
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

    private var accentCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Accent")
            Text("Ink follows appearance. Red, Blue, and Green stay the same in Light and Dark.")
                .inkText(.body)
            HStack(spacing: InkSpace.md) {
                ForEach(InkAccent.allCases) { option in
                    PaletteSwatchButton(
                        fill: option.resolved(against: palette.ink),
                        title: option.title,
                        isSelected: appearanceStore.accent == option
                    ) {
                        appearanceStore.selectAccent(option)
                    }
                }
            }
        }
    }

    private var paperCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Paper")
            Text("Dark paper only. Light stays white.")
                .inkText(.body)
            HStack(spacing: InkSpace.md) {
                ForEach(InkGround.allCases) { option in
                    PaletteSwatchButton(
                        fill: option.color,
                        title: option.title,
                        isSelected: appearanceStore.ground == option
                    ) {
                        appearanceStore.selectGround(option)
                    }
                }
            }
        }
    }

    private var radiusCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Radius")
            Text("Buttons, checkbox, list covers, and fields use Zero 0 / Sm 6 / Md 12 / Lg 16. Switch is fully rounded from Md.")
                .inkText(.body)
            HStack(spacing: InkSpace.md) {
                ForEach(InkRadius.allCases) { option in
                    Button(option.title) {
                        appearanceStore.selectRadius(option)
                    }
                    .modifier(AppearanceOptionStyle(isSelected: appearanceStore.radius == option))
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
            Text("Cover, title, caption, and a 32pt bar action. Small is 48 square, medium 72 square, large 96×72 (4:3). Cover corners follow the radius picker. Rows use a 2pt ink hairline. Last row drops the border.")
                .inkText(.body)

            VStack(spacing: 0) {
                InkListRow(title: "Small", description: "48 × 48") {
                    InkListCover {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("Start") {}
                        .inkBarFillButton()
                }

                InkListRow(title: "Medium", description: "72 × 72") {
                    InkListCover(size: .medium) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("More", systemImage: "ellipsis") {}
                        .inkBarIconOutlineButton()
                }

                InkListRow(
                    title: "Large",
                    description: "96 × 72 · 4:3",
                    showsBottomBorder: false
                ) {
                    InkListCover(size: .large) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(palette.ink)
                    }
                } action: {
                    Button("Start") {}
                        .inkBarFillButton()
                }
            }
        }
    }

    private var fieldCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Field")
            Text("Md is 44 and body. Sm is 32 and footnote. Both use a 12pt inset so text lines up. Corners follow the radius picker.")
                .inkText(.body)
            TextField("Prompt", text: $fieldText)
                .inkField()
            TextField("Search", text: $fieldSearch)
                .inkField(size: .sm)
            TextField("Disabled", text: $fieldDisabled)
                .inkField(enabled: false)
                .disabled(true)
        }
    }

    private var sheetCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Sheet")
            Text("Overlay card — 2pt ink stroke. Medium (10/20 inset) → Large (5/10 inset) → Full (edge-to-edge). Corner radius stays 24 until full. Confirm can drag through all three.")
                .inkText(.body)
            Button("List sheet") { showListSheet = true }
                .inkOutlineButton()
            Button("Form sheet") { showFormSheet = true }
                .inkOutlineButton()
            Button("Confirm sheet") { showConfirmSheet = true }
                .inkFillButton()
        }
    }

    private var dialogCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Dialog")
            Text("Centered overlay on an ink scrim — not a sheet. Alert requires a button; custom can dismiss on backdrop or close.")
                .inkText(.body)
            Button("Alert dialog") { showAlertDialog = true }
                .inkFillButton()
            Button("Custom dialog") { showCustomDialog = true }
                .inkOutlineButton()
        }
    }

    private var customDialog: some View {
        InkDialog(title: "Rename") {
            InkSheetCloseButton { showCustomDialog = false }
        } footer: {
            InkDialogFooter {
                Button("Save") { showCustomDialog = false }
                    .inkFillButton()
            }
        } content: {
            VStack(alignment: .leading, spacing: InkSpace.xs) {
                Text("NAME")
                    .inkText(.capital)
                TextField("Name", text: $dialogName)
                    .inkField()
            }
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
                        .inkField()
                }
                Text("Fields sit on paper with a 2pt stroke. Footer holds the full-width 44pt fill action.")
                    .inkText(.caption)
            }
        }
    }

    private var confirmSheet: some View {
        InkSheet(title: "Leave") {
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

    private var toggles: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Toggle")
            Text("32 tall, 52 wide. Fully rounded from Md; Sm and Zero share the same corner on track and knob.")
                .inkText(.body)
            Toggle("On", isOn: $toggleOn)
                .inkText(.body)
                .toggleStyle(.ink)
            Toggle("Off", isOn: $toggleOff)
                .inkText(.body)
                .toggleStyle(.ink)
            Toggle("Disabled", isOn: $toggleDisabled)
                .inkText(.body)
                .toggleStyle(.ink)
                .disabled(true)
        }
    }

    private var checkboxes: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Checkbox")
            Text("32 square. Corner matches the button radius. Off is 6% ink with a waiting hook. On fills accent.")
                .inkText(.body)
            Toggle("On", isOn: $checkboxOn)
                .inkText(.body)
                .toggleStyle(.inkCheckbox)
            Toggle("Off", isOn: $checkboxOff)
                .inkText(.body)
                .toggleStyle(.inkCheckbox)
            Toggle("Disabled", isOn: $checkboxDisabled)
                .inkText(.body)
                .toggleStyle(.inkCheckbox)
                .disabled(true)
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
        AppearanceRevealButton(option: option, isSelected: selected == option) { origin in
            appearanceStore.select(option, origin: origin)
        }
    }
}

private struct PaletteSwatchButton: View {
    var fill: Color
    var title: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    private let ringInset: CGFloat = 4

    var body: some View {
        let inner = inkRadius.button
        let ring = inner == 0 ? 0 : inner + ringInset
        Button(action: action) {
            RoundedRectangle(cornerRadius: inner, style: .continuous)
                .fill(fill)
                .frame(width: Ink.barButtonHeight, height: Ink.barButtonHeight)
                .padding(ringInset)
                .overlay {
                    RoundedRectangle(cornerRadius: ring, style: .continuous)
                        .stroke(palette.ink, lineWidth: Ink.borderWidth)
                        .opacity(isSelected ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct AppearanceRevealButton: View {
    let option: InkAppearance
    let isSelected: Bool
    let onSelect: (CGPoint) -> Void
    @State private var origin = CGPoint.zero

    var body: some View {
        Button(option.title) {
            onSelect(origin)
        }
        .modifier(AppearanceOptionStyle(isSelected: isSelected))
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { origin = center(in: proxy) }
                    .onChange(of: proxy.frame(in: .global)) { _, _ in
                        origin = center(in: proxy)
                    }
            }
        }
    }

    private func center(in proxy: GeometryProxy) -> CGPoint {
        let frame = proxy.frame(in: .global)
        return CGPoint(x: frame.midX, y: frame.midY)
    }
}

private struct AppearanceOptionStyle: ViewModifier {
    var isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content.inkFillButton()
        } else {
            content.inkOutlineButton()
        }
    }
}

#Preview {
    DesignSystemPlaygroundView()
        .environment(InkAppearanceStore())
        .inkAppearance(.system, accent: .ink, ground: .black, radius: .md)
}
