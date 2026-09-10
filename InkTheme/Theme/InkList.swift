import SwiftUI

enum InkListCoverSize: CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: Self { self }

    var width: CGFloat {
        switch self {
        case .small:
            Ink.listCoverSize
        case .medium:
            Ink.voiceSize
        case .large:
            Ink.listCoverSize * 2
        }
    }

    var height: CGFloat {
        switch self {
        case .small:
            Ink.listCoverSize
        case .medium, .large:
            Ink.voiceSize
        }
    }
}

struct InkListCover<Content: View>: View {
    var size: InkListCoverSize = .small
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
        ZStack {
            content()
        }
        .background(palette.paper)
        .frame(width: size.width, height: size.height)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
        }
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
