import SwiftUI

/// Overlay page chrome matching Flutter `InkPage`: frosted nav floats over body;
/// body scrolls underneath. Pad scroll content with ``navExtent`` / 
/// ``inkOverlayNavContentInset()`` so the first rows clear the bar.
///
/// Pass ``header`` to **replace** the default title text inside the nav
/// (custom leading chrome). Omit ``header`` to keep the string ``title``.
public struct InkPage<TitleAccessory: View, Actions: View, Header: View, Overlay: View, Body: View>: View {
    let title: String
    var frosted: Bool
    var frostedOpacity: CGFloat
    var titlePointSize: CGFloat?
    @ViewBuilder var titleAccessory: () -> TitleAccessory
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var header: () -> Header
    /// Page chrome between the scrolling body and the nav. Drawn under the header.
    @ViewBuilder var overlay: () -> Overlay
    @ViewBuilder var content: () -> Body

    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder titleAccessory: @escaping () -> TitleAccessory,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder overlay: @escaping () -> Overlay,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.title = title
        self.frosted = frosted
        self.frostedOpacity = frostedOpacity
        self.titlePointSize = titlePointSize
        self.titleAccessory = titleAccessory
        self.actions = actions
        self.header = header
        self.overlay = overlay
        self.content = content
    }

    private var usesCustomHeader: Bool {
        Header.self != EmptyView.self
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            overlay()

            if usesCustomHeader {
                header()
            } else {
                InkNavBar(
                    showHairline: true,
                    frosted: frosted,
                    frostedOpacity: frostedOpacity
                ) {
                    HStack(alignment: .center, spacing: InkSpace.sm) {
                        InkNavBarTitle(title, pointSize: titlePointSize)
                        titleAccessory()
                    }
                } actions: {
                    actions()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .inkScreen()
    }

    /// Top inset for scroll content under an overlay `InkNavBar`.
    /// Does not include status-bar safe area (layout already respects it).
    public static var navExtent: CGFloat { InkOverlayInset.nav }

    /// When the overlay also absorbs the status-bar safe area into the bar itself.
    public static func navExtent(safeTop: CGFloat, topPadding: CGFloat = InkSpace.sm) -> CGFloat {
        safeTop + topPadding + Ink.navBarHeight + InkSpace.sm
    }
}

extension InkPage where TitleAccessory == EmptyView, Overlay == EmptyView {
    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.init(
            title: title,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize,
            titleAccessory: { EmptyView() },
            actions: actions,
            header: header,
            overlay: { EmptyView() },
            content: content
        )
    }
}

extension InkPage where TitleAccessory == EmptyView {
    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder overlay: @escaping () -> Overlay,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.init(
            title: title,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize,
            titleAccessory: { EmptyView() },
            actions: actions,
            header: header,
            overlay: overlay,
            content: content
        )
    }
}

extension InkPage where TitleAccessory == EmptyView, Header == EmptyView, Overlay == EmptyView {
    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.init(
            title: title,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize,
            titleAccessory: { EmptyView() },
            actions: actions,
            header: { EmptyView() },
            overlay: { EmptyView() },
            content: content
        )
    }
}

extension InkPage where TitleAccessory == EmptyView, Actions == EmptyView, Header == EmptyView, Overlay == EmptyView {
    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.init(
            title: title,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize,
            titleAccessory: { EmptyView() },
            actions: { EmptyView() },
            header: { EmptyView() },
            overlay: { EmptyView() },
            content: content
        )
    }
}

extension InkPage where Header == EmptyView, Overlay == EmptyView {
    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder titleAccessory: @escaping () -> TitleAccessory,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.init(
            title: title,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize,
            titleAccessory: titleAccessory,
            actions: actions,
            header: { EmptyView() },
            overlay: { EmptyView() },
            content: content
        )
    }
}

/// Layout insets when nav / bottom tab overlay the body (content scrolls underneath).
public enum InkOverlayInset {
    /// Top pad for scroll content under an overlay `InkNavBar` (excludes status-bar safe area).
    public static var nav: CGFloat { InkSpace.sm + Ink.navBarHeight + InkSpace.sm }

    /// Bottom pad for scroll content under an overlay `InkBottomNav` (excludes home indicator).
    public static var tab: CGFloat { InkSpace.sm + Ink.buttonHeight }
}

private struct InkOverlayNavInsetKey: EnvironmentKey {
    nonisolated static let defaultValue: CGFloat = 0
}

private struct InkOverlayTabInsetKey: EnvironmentKey {
    nonisolated static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// Optional override for top overlay inset. `0` falls back to ``InkOverlayInset/nav``.
    public var inkOverlayNavInset: CGFloat {
        get { self[InkOverlayNavInsetKey.self] }
        set { self[InkOverlayNavInsetKey.self] = newValue }
    }

    /// Extra bottom inset when a frosted `InkBottomNav` overlays the tab root.
    /// Set by the app shell; scroll content and secondary bottom bars should clear it.
    public var inkOverlayTabInset: CGFloat {
        get { self[InkOverlayTabInsetKey.self] }
        set { self[InkOverlayTabInsetKey.self] = newValue }
    }
}

extension View {
    /// Pads the top of scroll content so it clears an overlay `InkNavBar` / `InkPage` chrome.
    /// Uses `inkOverlayNavInset` from the environment when set, else ``InkOverlayInset/nav``.
    public func inkOverlayNavContentInset() -> some View {
        modifier(InkOverlayNavContentInsetModifier())
    }

    /// Pads the bottom of scroll content so it clears an overlay `InkBottomNav`.
    /// Uses `inkOverlayTabInset` from the environment when set, else ``InkOverlayInset/tab``.
    public func inkOverlayTabContentInset() -> some View {
        modifier(InkOverlayTabContentInsetModifier())
    }
}

private struct InkOverlayNavContentInsetModifier: ViewModifier {
    @Environment(\.inkOverlayNavInset) private var navInset

    func body(content: Content) -> some View {
        content.padding(.top, navInset > 0 ? navInset : InkOverlayInset.nav)
    }
}

private struct InkOverlayTabContentInsetModifier: ViewModifier {
    @Environment(\.inkOverlayTabInset) private var tabInset

    func body(content: Content) -> some View {
        content.padding(.bottom, tabInset > 0 ? tabInset : InkOverlayInset.tab)
    }
}
