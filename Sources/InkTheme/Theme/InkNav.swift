import SwiftUI

public struct InkNavBar<Actions: View>: View {
    let title: String
    var topPadding: CGFloat
    /// 2pt ink hairline under the bar (matches Flutter `showHairline` / bottom nav).
    var showHairline: Bool
    /// Blur + translucent paper so content can show through when the bar overlays a scroll view.
    var frosted: Bool
    var frostedOpacity: CGFloat
    /// Title point size override (Flutter `titleFontSize`). `nil` uses hero.
    var titlePointSize: CGFloat?
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var actions: () -> Actions

    public init(
        title: String,
        topPadding: CGFloat = InkSpace.sm,
        showHairline: Bool = true,
        frosted: Bool = false,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = nil,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.title = title
        self.topPadding = topPadding
        // Frosted overlay always draws the hairline (Flutter: showHairline || frosted).
        self.showHairline = showHairline || frosted
        self.frosted = frosted
        self.frostedOpacity = frostedOpacity
        self.titlePointSize = titlePointSize
        self.actions = actions
    }

    public var body: some View {
        HStack(alignment: .center, spacing: InkSpace.sm) {
            Group {
                if let titlePointSize {
                    Text(title)
                        .inkText(.hero, pointSize: titlePointSize)
                } else {
                    Text(title)
                        .inkText(.hero)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: InkSpace.sm) {
                actions()
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, InkSpace.sm)
        .padding(.horizontal, InkSpace.xl)
        .frame(minHeight: Ink.navBarHeight, alignment: .center)
        .background {
            InkChromeBackground(frosted: frosted, frostedOpacity: frostedOpacity, safeEdges: .top)
        }
        .overlay(alignment: .bottom) {
            if showHairline {
                Rectangle()
                    .fill(palette.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }

    /// Total bar height including top safe area — use as scroll content top inset when overlaying.
    public static func extent(topSafeArea: CGFloat, topPadding: CGFloat = InkSpace.sm) -> CGFloat {
        topSafeArea + topPadding + Ink.navBarHeight + InkSpace.sm
    }
}

extension InkNavBar where Actions == EmptyView {
    public init(
        title: String,
        topPadding: CGFloat = InkSpace.sm,
        showHairline: Bool = true,
        frosted: Bool = false,
        frostedOpacity: CGFloat = Ink.frostedOpacity,
        titlePointSize: CGFloat? = nil
    ) {
        self.init(
            title: title,
            topPadding: topPadding,
            showHairline: showHairline,
            frosted: frosted,
            frostedOpacity: frostedOpacity,
            titlePointSize: titlePointSize
        ) {
            EmptyView()
        }
    }
}
