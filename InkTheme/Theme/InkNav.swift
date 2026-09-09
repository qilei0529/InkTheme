import SwiftUI

struct InkNavBar<Actions: View>: View {
    let title: String
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
        .padding(.horizontal, InkSpace.xl)
        .padding(.vertical, InkSpace.sm)
        .background(Ink.paper)
    }
}

extension InkNavBar where Actions == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}
