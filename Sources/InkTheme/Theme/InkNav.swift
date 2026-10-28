import SwiftUI

public struct InkNavBar<Actions: View>: View {
    let title: String
    var topPadding: CGFloat
    /// 2pt ink hairline under the bar (matches Flutter `showHairline` / bottom nav).
    var showHairline: Bool
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var actions: () -> Actions

    public init(
        title: String,
        topPadding: CGFloat = InkSpace.sm,
        showHairline: Bool = true,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.title = title
        self.topPadding = topPadding
        self.showHairline = showHairline
        self.actions = actions
    }

    public var body: some View {
        HStack(alignment: .center, spacing: InkSpace.sm) {
            Text(title)
                .inkText(.hero)
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
        .background(palette.paper)
        .overlay(alignment: .bottom) {
            if showHairline {
                Rectangle()
                    .fill(palette.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }
}

extension InkNavBar where Actions == EmptyView {
    public init(
        title: String,
        topPadding: CGFloat = InkSpace.sm,
        showHairline: Bool = true
    ) {
        self.init(title: title, topPadding: topPadding, showHairline: showHairline) {
            EmptyView()
        }
    }
}
