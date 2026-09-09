import SwiftUI

struct InkNavBar<Actions: View>: View {
    let title: String
    var topPadding: CGFloat = InkSpace.sm
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var actions: () -> Actions

    var body: some View {
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
    init(title: String, topPadding: CGFloat = InkSpace.sm) {
        self.init(title: title, topPadding: topPadding) { EmptyView() }
    }
}
