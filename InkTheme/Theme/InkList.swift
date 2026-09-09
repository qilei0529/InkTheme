import SwiftUI

struct InkListCover<Content: View>: View {
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            content()
        }
        .background(palette.paper)
        .frame(width: Ink.listCoverSize, height: Ink.listCoverSize)
        .clipShape(RoundedRectangle(cornerRadius: Ink.cornerRadius, style: .continuous))
        .inkStroke()
    }
}

struct InkListRow<Cover: View, Action: View>: View {
    let title: String
    let description: String
    var showsBottomBorder: Bool = true
    @Environment(\.inkPalette) private var palette
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
                    .fill(palette.ink)
                    .frame(height: Ink.borderWidth)
            }
        }
    }
}
