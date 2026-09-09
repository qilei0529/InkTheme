import SwiftUI

struct InkListCover<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Ink.paper
            content()
        }
        .frame(width: Ink.listCoverSize, height: Ink.listCoverSize)
        .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
        .inkStroke()
    }
}

struct InkListRow<Cover: View, Action: View>: View {
    let title: String
    let description: String
    var showsBottomBorder: Bool = true
    @ViewBuilder var cover: () -> Cover
    @ViewBuilder var action: () -> Action

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: InkSpace.md) {
                cover()

                VStack(alignment: .leading, spacing: InkSpace.xxs) {
                    Text(title)
                        .inkText(.bodyStrong)
                        .lineLimit(1)
                    Text(description)
                        .inkText(.caption)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                action()
            }
            .padding(.vertical, InkSpace.lg)

            if showsBottomBorder {
                Rectangle()
                    .fill(Ink.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }
}
