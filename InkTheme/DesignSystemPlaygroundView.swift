import InkTheme
import SwiftUI

struct DesignSystemPlaygroundView: View {
    @State private var isListening = false
    @State private var toggleOn = true
    @State private var toggleOff = false
    @State private var toggleDisabled = false
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
    @State private var bottomTab = PlaygroundTab.home
    @State private var showTabLabels = true
    @Environment(InkAppearanceStore.self) private var appearanceStore
    @Environment(\.inkPalette) private var palette

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    Group {
                        switch bottomTab {
                        case .home:
                            catalog
                        case .ask:
                            askDemo
                        case .history:
                            historyDemo
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    InkNavBar(title: bottomTab.title, frosted: true) {
                        Button("Settings") {}
                            .inkBarOutlineButton()
                        Button("Add", systemImage: "plus") {}
                            .inkBarIconFillButton()
                    }
                }

                InkBottomNav(
                    items: PlaygroundTab.items,
                    selection: $bottomTab,
                    showLabels: showTabLabels,
                    frosted: true
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.inkOverlayTabInset, InkOverlayInset.tab)
            .inkScreen()
            .toolbar(.hidden, for: .navigationBar)
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

    private var catalog: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: InkSpace.section) {
                intro
                appearanceCatalog
                themeCatalog
                radiusCatalog
                typeCatalog
                spaceCatalog
                navCatalog
                bottomNavCatalog
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
            .inkOverlayNavContentInset()
            .inkOverlayTabContentInset()
            .inkDismissKeyboardOnTap()
        }
    }

    private var askDemo: some View {
        VStack(alignment: .leading, spacing: InkSpace.lg) {
            Text("PROMPT")
                .inkText(.capital)
            Text("Could you stay a bit later?")
                .inkText(.hero)
            Text("Ask is the selected tab. Frosted nav and bottom tab float over the body so content can scroll underneath.")
                .inkText(.body)
            Spacer(minLength: 0)
        }
        .padding(InkSpace.xl)
        .inkOverlayNavContentInset()
        .inkOverlayTabContentInset()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var historyDemo: some View {
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
            InkListRow(title: "Sam", description: "Yesterday", showsBottomBorder: false) {
                InkListCover {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(palette.ink)
                }
            } action: {
                Button("Start") {}
                    .inkBarOutlineButton()
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, InkSpace.xl)
        .padding(.top, InkSpace.sm)
        .inkOverlayNavContentInset()
        .inkOverlayTabContentInset()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: InkSpace.sm) {
            Text("INK / PAPER")
                .inkText(.caption)
            Text("Named type styles and spacing. Each color theme owns a full light and dark palette — ink, paper, accent, and inverse. Appearance flips between those two sides.")
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

    private var themeCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Theme")
            Text("One config per color. Red, Blue, and Green tint light paper and deep dark paper; fill uses accent in both.")
                .inkText(.body)
            HStack(spacing: InkSpace.md) {
                ForEach(InkColorTheme.all) { option in
                    PaletteSwatchButton(
                        fill: option.swatch,
                        title: option.title,
                        isSelected: appearanceStore.theme.id == option.id
                    ) {
                        appearanceStore.selectTheme(option)
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
            Text("Roles keep weight / tracking / opacity. Override size with InkTypeToken (xxs…x3l), e.g. .inkText(.body, size: .md).")
                .inkText(.body)
            ForEach(InkTextStyle.allCases) { style in
                VStack(alignment: .leading, spacing: InkSpace.xs) {
                    Text(style.sample)
                        .inkText(style)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(style.spec)
                        .inkText(.caption)
                }
            }

            sectionTitle("Type size")
            Text("Parallel to InkSpace. Prefer roles; use tokens when a screen needs a step on the ladder.")
                .inkText(.body)
            ForEach(InkTypeToken.allCases) { token in
                VStack(alignment: .leading, spacing: InkSpace.xxs) {
                    Text("The quick brown fox — \(token.rawValue) \(Int(token.value))")
                        .inkText(.body, size: token)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(token.usage)
                        .inkText(.caption)
                }
            }
            Text("body + md override")
                .inkText(.capital, size: .xxs)
            Text("Secondary body on a dense card.")
                .inkText(.body, size: .md)
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
            Text("Hero title at 28. Text actions hug at 32; icon actions are a 32 square. Prefer `InkPage` / overlay with `frosted: true` (blur + paper at \(Ink.frostedOpacity) alpha) so content scrolls underneath. Pad scroll content with `inkOverlayNavContentInset()`. Opaque `safeAreaInset` is fine when frosted overlay is not needed. Sheets keep non-frosted nav.")
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

    private var bottomNavCatalog: some View {
        VStack(alignment: .leading, spacing: InkSpace.md) {
            sectionTitle("Bottom Nav")
            Text("This page overlays a frosted bar and switches HOME, ASK, and HISTORY. Use `frosted: true` in a bottom ZStack so rows blur under the tabs; pad scroll content with `inkOverlayTabContentInset()`. Selected is full ink; the rest stay at capital opacity. Turn off Labels for icon-only (22pt); the label stays the accessibility name.")
                .inkText(.body)
            Toggle("Labels", isOn: $showTabLabels)
                .inkText(.body)
                .toggleStyle(.ink)
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
            HStack(spacing: InkSpace.md) {
                Button("Add", systemImage: "plus") {}
                    .inkIconFillButton()
                Button("Close", systemImage: "xmark") {}
                    .inkIconOutlineButton()
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

private enum PlaygroundTab: String, CaseIterable, Hashable {
    case home
    case ask
    case history

    var title: String {
        switch self {
        case .home: "Ink"
        case .ask: "Ask"
        case .history: "History"
        }
    }

    var label: String {
        switch self {
        case .home: "HOME"
        case .ask: "ASK"
        case .history: "HISTORY"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .ask: "mic"
        case .history: "clock"
        }
    }

    static var items: [InkTabItem<PlaygroundTab>] {
        allCases.map { InkTabItem(id: $0, label: $0.label, systemImage: $0.systemImage) }
    }
}

#Preview {
    DesignSystemPlaygroundView()
        .environment(InkAppearanceStore())
        .inkAppearance(.system, theme: .ink, radius: .md)
        .inkKeyboardBar()
}
