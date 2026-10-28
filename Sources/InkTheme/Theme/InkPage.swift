import SwiftUI

/// Overlay page chrome matching Flutter `InkPage`: frosted nav floats over body;
/// body scrolls underneath. Pad scroll content with ``navExtent`` so the first
/// rows clear the bar (both chrome and body sit in the layout safe area; the
/// frosted fill extends under the status bar via ``InkChromeBackground``).
public struct InkPage<Actions: View, Body: View>: View {
    let title: String
    var frosted: Bool
    var frostedOpacity: CGFloat
    var titlePointSize: CGFloat?
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var content: () -> Body

    public init(
        title: String,
        frosted: Bool = true,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = 22,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.title = title
        self.frosted = frosted
        self.frostedOpacity = frostedOpacity
        self.titlePointSize = titlePointSize
        self.actions = actions
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            InkNavBar(
                title: title,
                showHairline: true,
                frosted: frosted,
                frostedOpacity: frostedOpacity,
                titlePointSize: titlePointSize,
                actions: actions
            )
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

extension InkPage where Actions == EmptyView {
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
            actions: { EmptyView() },
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

private struct InkOverlayTabInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// Extra bottom inset when a frosted `InkBottomNav` overlays the tab root.
    /// Set by the app shell; scroll content and secondary bottom bars should clear it.
    public var inkOverlayTabInset: CGFloat {
        get { self[InkOverlayTabInsetKey.self] }
        set { self[InkOverlayTabInsetKey.self] = newValue }
    }
}

extension View {
    /// Pads the top of scroll content so it clears an overlay `InkNavBar`.
    public func inkOverlayNavContentInset() -> some View {
        padding(.top, InkOverlayInset.nav)
    }

    /// Pads the bottom of scroll content so it clears an overlay `InkBottomNav`.
    /// Uses `inkOverlayTabInset` from the environment when set, else ``InkOverlayInset/tab``.
    public func inkOverlayTabContentInset() -> some View {
        modifier(InkOverlayTabContentInsetModifier())
    }
}

private struct InkOverlayTabContentInsetModifier: ViewModifier {
    @Environment(\.inkOverlayTabInset) private var tabInset

    func body(content: Content) -> some View {
        content.padding(.bottom, tabInset > 0 ? tabInset : InkOverlayInset.tab)
    }
}
