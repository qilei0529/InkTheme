import SwiftUI

enum InkSheetDetent: String, CaseIterable, Identifiable {
    case large
    case medium
    case mediumAndLarge

    var id: String { rawValue }

    var presentationDetents: Set<PresentationDetent> {
        switch self {
        case .large:
            [.large]
        case .medium:
            [.medium]
        case .mediumAndLarge:
            [.medium, .large]
        }
    }
}

struct InkSheet<Actions: View, Footer: View, Content: View>: View {
    let title: String
    var detent: InkSheetDetent = .large
    var showsDragIndicator: Bool = true
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var footer: () -> Footer
    @ViewBuilder var content: () -> Content

    var body: some View {
        sheetStack
            .clipShape(RoundedRectangle(cornerRadius: Ink.sheetCornerRadius, style: .continuous))
            .padding(.bottom, floatsAboveScreenEdge ? Ink.sheetScreenInset : 0)
            .presentationDetents(detent.presentationDetents)
            .presentationDragIndicator(showsDragIndicator ? .visible : .hidden)
            .presentationCornerRadius(Ink.sheetCornerRadius)
            .presentationBackground(Ink.paper)
    }

    private var floatsAboveScreenEdge: Bool {
        detent == .medium
    }

    private var sheetStack: some View {
        NavigationStack {
            content()
                .inkScreen()
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .top) {
                    InkNavBar(title: title, topPadding: InkSpace.xl, actions: actions)
                }
                .safeAreaInset(edge: .bottom) {
                    footer()
                }
        }
    }
}

struct InkSheetCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button("Close", systemImage: "xmark", action: action)
            .inkBarIconOutlineButton()
    }
}

extension InkSheet where Actions == EmptyView, Footer == EmptyView {
    init(
        title: String,
        detent: InkSheetDetent = .large,
        showsDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            detent: detent,
            showsDragIndicator: showsDragIndicator,
            actions: { EmptyView() },
            footer: { EmptyView() },
            content: content
        )
    }
}

extension InkSheet where Footer == EmptyView {
    init(
        title: String,
        detent: InkSheetDetent = .large,
        showsDragIndicator: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            detent: detent,
            showsDragIndicator: showsDragIndicator,
            actions: actions,
            footer: { EmptyView() },
            content: content
        )
    }
}

struct InkSheetBody<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: InkSpace.xl) {
                content()
            }
            .padding(InkSpace.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InkSheetList<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        List {
            content()
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.horizontal, InkSpace.xl, for: .scrollContent)
        .contentMargins(.vertical, InkSpace.sm, for: .scrollContent)
    }
}

extension View {
    func inkSheetListRow() -> some View {
        listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Ink.paper)
    }
}

struct InkSheetFooter<Content: View>: View {
    var showsHairline: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: InkSpace.md) {
            content()
        }
        .padding(InkSpace.xl)
        .frame(maxWidth: .infinity)
        .background(Ink.paper)
        .overlay(alignment: .top) {
            if showsHairline {
                Rectangle()
                    .fill(Ink.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }
}
