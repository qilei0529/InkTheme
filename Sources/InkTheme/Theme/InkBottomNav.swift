import SwiftUI

public enum InkTabIcon: Hashable {
    case system(String)
    case asset(String)
}

public struct InkTabItem<ID: Hashable>: Identifiable {
    public let id: ID
    public let label: String
    public let icon: InkTabIcon

    public init(id: ID, label: String, systemImage: String) {
        self.id = id
        self.label = label
        self.icon = .system(systemImage)
    }

    public init(id: ID, label: String, image: String) {
        self.id = id
        self.label = label
        self.icon = .asset(image)
    }
}

public struct InkBottomNav<ID: Hashable>: View {
    let items: [InkTabItem<ID>]
    @Binding var selection: ID
    /// When `false`, only the icon is shown. `label` remains the accessibility name.
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
                        icon: item.icon,
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
                .fill(palette.border)
                .frame(height: Ink.borderWidth)
        }
    }
}

private struct InkBottomNavItem: View {
    let label: String
    let icon: InkTabIcon
    let isSelected: Bool
    let showLabel: Bool
    @Environment(\.inkPalette) private var palette

    private var iconSize: CGFloat { showLabel ? 18 : 22 }

    var body: some View {
        Group {
            if showLabel {
                VStack(spacing: InkSpace.xxs) {
                    iconView
                    Text(label)
                        .font(.system(size: 10, weight: .regular))
                }
            } else {
                iconView
            }
        }
        .foregroundStyle(palette.ink.opacity(isSelected ? 1 : InkTextStyle.capital.inkOpacity))
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: iconSize, weight: .semibold))
        case .asset(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
        }
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
