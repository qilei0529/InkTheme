import SwiftUI

public struct InkTabItem<ID: Hashable>: Identifiable {
    public let id: ID
    public let label: String
    public let systemImage: String

    public init(id: ID, label: String, systemImage: String) {
        self.id = id
        self.label = label
        self.systemImage = systemImage
    }
}

public struct InkBottomNav<ID: Hashable>: View {
    let items: [InkTabItem<ID>]
    @Binding var selection: ID
    /// When `false`, only the SF Symbol is shown. `label` remains the accessibility name.
    var showLabels: Bool
    /// Blur + translucent paper so content can show through when the bar overlays a scroll view.
    var frosted: Bool
    var frostedOpacity: CGFloat
    @Environment(\.inkPalette) private var palette

    public init(
        items: [InkTabItem<ID>],
        selection: Binding<ID>,
        showLabels: Bool = true,
        frosted: Bool = false,
        frostedOpacity: CGFloat = Ink.frostedOpacity
    ) {
        self.items = items
        _selection = selection
        self.showLabels = showLabels
        self.frosted = frosted
        self.frostedOpacity = frostedOpacity
    }

    /// Content row height (excludes home-indicator safe area).
    public static var contentHeight: CGFloat {
        InkSpace.sm + Ink.buttonHeight
    }

    /// Total height including bottom safe area — use as scroll content bottom inset when overlaying.
    public static func extent(bottomSafeArea: CGFloat) -> CGFloat {
        contentHeight + bottomSafeArea
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    selection = item.id
                } label: {
                    InkBottomNavItem(
                        label: item.label,
                        systemImage: item.systemImage,
                        isSelected: selection == item.id,
                        showLabel: showLabels
                    )
                }
                .buttonStyle(InkBottomNavButtonStyle())
                .accessibilityLabel(item.label)
            }
        }
        .padding(.top, InkSpace.sm)
        .background {
            InkChromeBackground(frosted: frosted, frostedOpacity: frostedOpacity, safeEdges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.ink)
                .frame(height: Ink.borderWidth)
        }
    }
}

private struct InkBottomNavItem: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    let showLabel: Bool
    @Environment(\.inkPalette) private var palette

    var body: some View {
        Group {
            if showLabel {
                VStack(spacing: InkSpace.xxs) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                    Text(label)
                        .font(.system(size: 10, weight: .regular))
                }
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
            }
        }
        .foregroundStyle(palette.ink.opacity(isSelected ? 1 : InkTextStyle.capital.inkOpacity))
    }
}

private struct InkBottomNavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}
