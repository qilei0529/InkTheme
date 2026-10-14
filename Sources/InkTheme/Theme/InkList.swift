import SwiftUI

public enum InkListCoverSize: CaseIterable, Identifiable {
    case small
    case medium
    case large

    public var id: Self { self }

    public var width: CGFloat {
        switch self {
        case .small:
            Ink.listCoverSize
        case .medium:
            Ink.voiceSize
        case .large:
            Ink.listCoverSize * 2
        }
    }

    public var height: CGFloat {
        switch self {
        case .small:
            Ink.listCoverSize
        case .medium, .large:
            Ink.voiceSize
        }
    }
}

public struct InkListCover<Content: View>: View {
    var size: InkListCoverSize
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
    @ViewBuilder var content: () -> Content

    public init(size: InkListCoverSize = .small, @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.content = content
    }

    public var body: some View {
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

public struct InkListRow<Cover: View, Action: View>: View {
    let title: String
    let description: String
    var showsBottomBorder: Bool
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var cover: () -> Cover
    @ViewBuilder var action: () -> Action

    public init(
        title: String,
        description: String,
        showsBottomBorder: Bool = true,
        @ViewBuilder cover: @escaping () -> Cover,
        @ViewBuilder action: @escaping () -> Action
    ) {
        self.title = title
        self.description = description
        self.showsBottomBorder = showsBottomBorder
        self.cover = cover
        self.action = action
    }

    public var body: some View {
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
