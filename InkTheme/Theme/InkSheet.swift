import SwiftUI

enum InkSheetDetent: String, CaseIterable, Identifiable {
    case medium
    case large
    case full
    case mediumAndLarge
    case largeAndFull
    case mediumAndFull

    var id: String { rawValue }

    static func mediumHeight(available: CGFloat) -> CGFloat {
        available * Ink.sheetMediumFraction
    }

    static func largeHeight(available: CGFloat) -> CGFloat {
        available * Ink.sheetLargeFraction
    }

    static func fullHeight(available: CGFloat) -> CGFloat {
        available
    }

    func allowedHeights(available: CGFloat) -> [CGFloat] {
        let medium = Self.mediumHeight(available: available)
        let large = Self.largeHeight(available: available)
        let full = Self.fullHeight(available: available)
        switch self {
        case .medium:
            return [medium]
        case .large:
            return [large]
        case .full:
            return [full]
        case .mediumAndLarge:
            return [medium, large]
        case .largeAndFull:
            return [large, full]
        case .mediumAndFull:
            return [medium, large, full]
        }
    }

    func initialHeight(available: CGFloat) -> CGFloat {
        allowedHeights(available: available).first ?? available
    }

    /// Chrome progress: `0` medium, `0.5` large, `1` full.
    func chromeProgress(height: CGFloat, available: CGFloat) -> CGFloat {
        switch self {
        case .medium:
            return 0
        case .large:
            return 0.5
        case .full:
            return 1
        case .mediumAndLarge:
            return Self.progress(height: height, available: available, from: .medium, to: .large)
        case .largeAndFull:
            return Self.progress(height: height, available: available, from: .large, to: .full)
        case .mediumAndFull:
            return Self.progressAcrossThree(height: height, available: available)
        }
    }

    private static func anchorProgress(for stop: ChromeStop) -> CGFloat {
        switch stop {
        case .medium: 0
        case .large: 0.5
        case .full: 1
        }
    }

    private static func height(for stop: ChromeStop, available: CGFloat) -> CGFloat {
        switch stop {
        case .medium: mediumHeight(available: available)
        case .large: largeHeight(available: available)
        case .full: fullHeight(available: available)
        }
    }

    private static func progress(
        height currentHeight: CGFloat,
        available: CGFloat,
        from: ChromeStop,
        to: ChromeStop
    ) -> CGFloat {
        let startH = height(for: from, available: available)
        let endH = height(for: to, available: available)
        let startP = anchorProgress(for: from)
        let endP = anchorProgress(for: to)
        let span = endH - startH
        guard span > 0 else { return endP }
        let t = min(max((currentHeight - startH) / span, 0), 1)
        return startP + (endP - startP) * t
    }

    private static func progressAcrossThree(height: CGFloat, available: CGFloat) -> CGFloat {
        let medium = mediumHeight(available: available)
        let large = largeHeight(available: available)
        let full = fullHeight(available: available)
        if height <= medium { return 0 }
        if height >= full { return 1 }
        if height <= large {
            let span = large - medium
            guard span > 0 else { return 0.5 }
            return 0.5 * min(max((height - medium) / span, 0), 1)
        }
        let span = full - large
        guard span > 0 else { return 1 }
        return 0.5 + 0.5 * min(max((height - large) / span, 0), 1)
    }

    private enum ChromeStop {
        case medium
        case large
        case full
    }
}

enum InkSheetChrome {
    static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    /// Piecewise: medium `10` → large `5` → full `0`.
    static func horizontalInset(progress: CGFloat) -> CGFloat {
        if progress <= 0.5 {
            return lerp(Ink.sheetMediumHorizontalInset, Ink.sheetLargeHorizontalInset, progress / 0.5)
        }
        return lerp(Ink.sheetLargeHorizontalInset, 0, (progress - 0.5) / 0.5)
    }

    /// Piecewise: medium `20` → large `10` → full `0`.
    static func verticalInset(progress: CGFloat) -> CGFloat {
        if progress <= 0.5 {
            return lerp(Ink.sheetScreenInset, Ink.sheetLargeVerticalInset, progress / 0.5)
        }
        return lerp(Ink.sheetLargeVerticalInset, 0, (progress - 0.5) / 0.5)
    }

    /// Medium and large keep `sheetCornerRadius`; full lerps to 0. Radius token `zero` stays square.
    static func cornerRadius(progress: CGFloat, radius: InkRadius) -> CGFloat {
        guard radius != .zero else { return 0 }
        if progress <= 0.5 {
            return Ink.sheetCornerRadius
        }
        return lerp(Ink.sheetCornerRadius, 0, (progress - 0.5) / 0.5)
    }

    /// Gap from screen edge to card. Medium/large include safe area + chrome; full is 0.
    static func outerInsets(progress: CGFloat, safe: EdgeInsets) -> EdgeInsets {
        let h = horizontalInset(progress: progress)
        let v = verticalInset(progress: progress)
        let safeFactor = progress <= 0.5 ? 1 : max(0, 1 - (progress - 0.5) / 0.5)
        return EdgeInsets(
            top: safe.top * safeFactor + v,
            leading: safe.leading * safeFactor + h,
            bottom: safe.bottom * safeFactor + v,
            trailing: safe.trailing * safeFactor + h
        )
    }

    /// Content inset inside paper. Only grows from large → full (medium/large cards already clear safe area).
    static func contentSafeInsets(progress: CGFloat, safe: EdgeInsets) -> EdgeInsets {
        let t = progress <= 0.5 ? 0 : (progress - 0.5) / 0.5
        return EdgeInsets(
            top: (safe.top + Ink.sheetFullTopExtra) * t,
            leading: safe.leading * t,
            bottom: safe.bottom * t,
            trailing: safe.trailing * t
        )
    }
}

struct InkSheet<Actions: View, Footer: View, Content: View>: View {
    let title: String
    var showsDragIndicator: Bool = true
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkSheetChromeRadius) private var chromeRadius
    @Environment(\.inkSheetContentSafeInsets) private var contentSafeInsets
    @Environment(\.inkSheetDrag) private var sheetDrag
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var footer: () -> Footer
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            handle
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .inkScreen()
            footer()
        }
        .padding(contentSafeInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.paper)
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: chromeRadius, style: .continuous)
    }

    private var handle: some View {
        VStack(spacing: 0) {
            if showsDragIndicator {
                Capsule()
                    .fill(palette.ink)
                    .frame(width: 36, height: Ink.borderWidth)
                    .padding(.top, InkSpace.sm)
                    .frame(maxWidth: .infinity)
            }

            InkNavBar(
                title: title,
                topPadding: showsDragIndicator ? InkSpace.sm : InkSpace.xl,
                actions: actions
            )
        }
        .contentShape(Rectangle())
        .gesture(handleDrag)
    }

    private var handleDrag: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                sheetDrag?.onChanged(value.translation.height)
            }
            .onEnded { value in
                sheetDrag?.onEnded(value.translation.height)
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
        showsDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
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
        showsDragIndicator: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
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
        modifier(InkSheetListRowModifier())
    }

    func inkSheet<Sheet: View>(
        isPresented: Binding<Bool>,
        detent: InkSheetDetent = .large,
        dismissOnBackdrop: Bool = true,
        @ViewBuilder sheet: @escaping () -> Sheet
    ) -> some View {
        modifier(
            InkSheetOverlayModifier(
                isPresented: isPresented,
                detent: detent,
                dismissOnBackdrop: dismissOnBackdrop,
                sheet: sheet
            )
        )
    }
}

private struct InkSheetListRowModifier: ViewModifier {
    @Environment(\.inkPalette) private var palette

    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Rectangle().fill(palette.paper))
    }
}

struct InkSheetFooter<Content: View>: View {
    var showsHairline: Bool = true
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: InkSpace.md) {
            content()
        }
        .padding(InkSpace.xl)
        .frame(maxWidth: .infinity)
        .background(palette.paper)
        .overlay(alignment: .top) {
            if showsHairline {
                Rectangle()
                    .fill(palette.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }
}

struct InkSheetDragHandlers {
    var onChanged: (CGFloat) -> Void
    var onEnded: (CGFloat) -> Void
}

private struct InkSheetDragKey: EnvironmentKey {
    static let defaultValue: InkSheetDragHandlers? = nil
}

private struct InkSheetChromeRadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat = Ink.sheetCornerRadius
}

private struct InkSheetContentSafeInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    var inkSheetDrag: InkSheetDragHandlers? {
        get { self[InkSheetDragKey.self] }
        set { self[InkSheetDragKey.self] = newValue }
    }

    var inkSheetChromeRadius: CGFloat {
        get { self[InkSheetChromeRadiusKey.self] }
        set { self[InkSheetChromeRadiusKey.self] = newValue }
    }

    var inkSheetContentSafeInsets: EdgeInsets {
        get { self[InkSheetContentSafeInsetsKey.self] }
        set { self[InkSheetContentSafeInsetsKey.self] = newValue }
    }
}

private struct InkSheetOverlayModifier<Sheet: View>: ViewModifier {
    @Binding var isPresented: Bool
    var detent: InkSheetDetent
    var dismissOnBackdrop: Bool
    @ViewBuilder var sheet: () -> Sheet
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var availableHeight: CGFloat = 0
    @State private var settledHeight: CGFloat = 0
    @State private var dragTranslation: CGFloat = 0
    /// Keeps chrome on-screen through the move-out; `isPresented` may already be false.
    @State private var isVisible = false
    /// Appear starts at `sheetMoveInOffset`; rest is 0; dismiss eases to the sheet height (system-like Y+h).
    @State private var verticalOffset: CGFloat = 0
    @State private var isAtRest = false
    @State private var dismissTask: Task<Void, Never>?

    private let appearDuration: TimeInterval = 0.22
    private let dismissDuration: TimeInterval = 0.2

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if isVisible {
                        palette.ink
                            .opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture {
                                guard dismissOnBackdrop, isAtRest else { return }
                                dismiss()
                            }
                            .accessibilityHidden(true)
                            .transition(.identity)

                        GeometryReader { geo in
                            let available = geo.size.height
                            let safe = geo.safeAreaInsets
                            let height = displayedHeight(in: available)
                            let progress = detent.chromeProgress(height: height, available: available)
                            let outer = InkSheetChrome.outerInsets(progress: progress, safe: safe)
                            let contentSafe = InkSheetChrome.contentSafeInsets(progress: progress, safe: safe)
                            let radius = InkSheetChrome.cornerRadius(progress: progress, radius: inkRadius)
                            let cardHeight = min(
                                height,
                                max(available - outer.top - outer.bottom, 0)
                            )

                            sheet()
                                .frame(height: cardHeight)
                                .environment(\.inkSheetChromeRadius, radius)
                                .environment(\.inkSheetContentSafeInsets, contentSafe)
                                .environment(\.inkSheetDrag, InkSheetDragHandlers(
                                    onChanged: { translation in
                                        dragTranslation = translation
                                    },
                                    onEnded: { translation in
                                        finishDrag(translation, available: available)
                                    }
                                ))
                                .padding(outer)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .offset(y: verticalOffset)
                                .opacity(available > 0 ? 1 : 0)
                                .onAppear {
                                    syncAvailable(available, animated: false)
                                    runAppearAnimationIfNeeded()
                                }
                                .onChange(of: geo.size.height) { _, newHeight in
                                    syncAvailable(newHeight, animated: false)
                                }
                                .accessibilityAddTraits(.isModal)
                        }
                        .ignoresSafeArea()
                        .transition(.identity)
                    }
                }
                .allowsHitTesting(isVisible && isAtRest)
                .onChange(of: isPresented) { _, presented in
                    if presented {
                        present()
                    } else {
                        dismissAnimated()
                    }
                }
            }
    }

    private func displayedHeight(in available: CGFloat) -> CGFloat {
        let resolvedAvailable = available > 0 ? available : availableHeight
        let base = settledHeight > 0 ? settledHeight : detent.initialHeight(available: resolvedAvailable)
        return min(max(base - dragTranslation, 0), max(resolvedAvailable, 0))
    }

    private func syncAvailable(_ height: CGFloat, animated: Bool) {
        let update = {
            availableHeight = height
            if settledHeight == 0 {
                settledHeight = detent.initialHeight(available: height)
            } else {
                let allowed = detent.allowedHeights(available: height)
                settledHeight = allowed.min(by: { abs($0 - settledHeight) < abs($1 - settledHeight) }) ?? height
            }
        }
        if animated {
            update()
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction, update)
        }
    }

    private func finishDrag(_ translation: CGFloat, available: CGFloat) {
        let current = displayedHeight(in: available)
        let allowed = detent.allowedHeights(available: available)
        let shortest = allowed.min() ?? available * Ink.sheetMediumFraction
        let dismissThreshold = min(80, shortest * 0.5)

        // Keep the on-screen height continuous: park at `current` before clearing drag.
        settledHeight = current
        dragTranslation = 0

        if current < shortest - dismissThreshold {
            dismiss()
            return
        }

        let target = allowed.min(by: { abs($0 - current) < abs($1 - current) }) ?? shortest
        if reduceMotion {
            settledHeight = target
        } else {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                settledHeight = target
            }
        }
    }

    private func present() {
        dismissTask?.cancel()
        dismissTask = nil
        dragTranslation = 0
        settledHeight = 0
        availableHeight = 0
        isAtRest = false
        verticalOffset = reduceMotion ? 0 : Ink.sheetMoveInOffset
        isVisible = true
    }

    private func runAppearAnimationIfNeeded() {
        guard isVisible, !isAtRest else { return }
        guard !reduceMotion else {
            verticalOffset = 0
            isAtRest = true
            return
        }
        withAnimation(.easeOut(duration: appearDuration)) {
            verticalOffset = 0
            isAtRest = true
        }
    }

    private func dismiss() {
        isPresented = false
    }

    private func dismissAnimated() {
        dismissTask?.cancel()
        guard isVisible else {
            resetDetentState()
            return
        }
        isAtRest = false
        // System sheet dismiss: slide down by the sheet height (Y + h) until off-screen.
        let distance = max(settledHeight, Ink.sheetMoveInOffset)
        guard !reduceMotion else {
            isVisible = false
            resetDetentState()
            return
        }
        withAnimation(.easeIn(duration: dismissDuration)) {
            verticalOffset = distance
        }
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(dismissDuration))
            guard !Task.isCancelled else { return }
            isVisible = false
            resetDetentState()
            dismissTask = nil
        }
    }

    private func resetDetentState() {
        dragTranslation = 0
        settledHeight = 0
        availableHeight = 0
        verticalOffset = 0
        isAtRest = false
    }
}
