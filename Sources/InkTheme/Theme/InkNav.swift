import SwiftUI

public struct InkNavBar<Actions: View>: View {
    let title: String
    var topPadding: CGFloat
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var actions: () -> Actions

    public init(
        title: String,
        topPadding: CGFloat = InkSpace.sm,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.title = title
        self.topPadding = topPadding
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
    }
}

extension InkNavBar where Actions == EmptyView {
    public init(title: String, topPadding: CGFloat = InkSpace.sm) {
        self.init(title: title, topPadding: topPadding) { EmptyView() }
    }
}
