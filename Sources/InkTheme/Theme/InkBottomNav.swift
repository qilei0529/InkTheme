import SwiftUI

public enum InkTabIcon: Hashable {
    case system(String)
    /// Asset catalog name; optional `selected` swaps in when the tab is active.
    case asset(String, selected: String?)
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

    public init(id: ID, label: String, image: String, selectedImage: String? = nil) {
        self.id = id
        self.label = label
        self.icon = .asset(image, selected: selectedImage)
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
    @Environment(\.inkRadius) private var inkRadius

    @State private var centers: [AnyHashable: CGFloat] = [:]
    @State private var fromX: CGFloat = 0
    @State private var toX: CGFloat = 0
    @State private var morphProgress: CGFloat = 1
    @State private var hasPlacedHighlight = false

    private let tabBarSpace = "inkTabBar"

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

    /// Content row height (excludes home-indicator safe area). Fixed whether labels are shown —
    /// labels are drawn with an offset and do not grow the bar.
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
                .background {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: InkTabCenterPreferenceKey.self,
                            value: [
                                AnyHashable(item.id): geo.frame(in: .named(tabBarSpace)).midX
                            ]
                        )
                    }
                }
            }
        }
        // Draw behind the tabs in the same bounds as `tabBarSpace` so midX matches the pill.
        .background {
            if hasPlacedHighlight {
                InkStretchTabHighlight(
                    fromX: fromX,
                    toX: toX,
                    progress: morphProgress,
                    cornerRadius: inkRadius.button,
                    color: palette.ink.opacity(0.05)
                )
                .allowsHitTesting(false)
            }
        }
        .coordinateSpace(name: tabBarSpace)
        .onPreferenceChange(InkTabCenterPreferenceKey.self, perform: applyCenters)
        .onChange(of: selection) { old, new in
            morphHighlight(from: old, to: new)
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

    private func applyCenters(_ newCenters: [AnyHashable: CGFloat]) {
        centers = newCenters
        // First layout often reports 0 / partial centers; wait until every tab has a real midX.
        guard items.allSatisfy({ item in
            (newCenters[AnyHashable(item.id)] ?? 0) > 0
        }),
        let x = newCenters[AnyHashable(selection)], x > 0
        else { return }

        if !hasPlacedHighlight {
            pinHighlight(to: x)
            return
        }

        // Re-pin while idle so a bad first frame (or rotation / width change) is corrected.
        guard morphProgress >= 1 else { return }
        guard abs(fromX - x) > 0.5 || abs(toX - x) > 0.5 else { return }
        pinHighlight(to: x)
    }

    private func pinHighlight(to x: CGFloat) {
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            fromX = x
            toX = x
            morphProgress = 1
            hasPlacedHighlight = true
        }
    }

    private func morphHighlight(from old: ID, to new: ID) {
        guard let from = centers[AnyHashable(old)],
              let to = centers[AnyHashable(new)]
        else { return }
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            fromX = from
            toX = to
            morphProgress = 0
        }
        withAnimation(.easeInOut(duration: 0.28)) {
            morphProgress = 1
        }
    }
}

/// Stretch-then-shrink selection pill: widens toward the target mid-travel, then settles.
private struct InkStretchTabHighlight: View {
    var fromX: CGFloat
    var toX: CGFloat
    var progress: CGFloat
    var cornerRadius: CGFloat
    var color: Color

    static let baseWidth: CGFloat = 54
    static let height: CGFloat = 36

    var body: some View {
        InkStretchTabHighlightShape(
            fromX: fromX,
            toX: toX,
            progress: progress,
            cornerRadius: cornerRadius
        )
        .fill(color)
        .frame(maxWidth: .infinity, minHeight: Ink.buttonHeight, maxHeight: Ink.buttonHeight)
    }
}

/// Shape so `progress` animates via SwiftUI’s geometry interpolation.
private struct InkStretchTabHighlightShape: Shape {
    var fromX: CGFloat
    var toX: CGFloat
    var progress: CGFloat
    var cornerRadius: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let half = InkStretchTabHighlight.baseWidth / 2
        let fromLeft = fromX - half
        let fromRight = fromX + half
        let toLeft = toX - half
        let toRight = toX + half
        // Lead edge reaches the target first; lag edge holds, then catches up.
        // Stretch only in the travel direction — never expands backward.
        let leadT = min(1, progress * 2)
        let lagT = max(0, progress * 2 - 1)
        let left: CGFloat
        let right: CGFloat
        if toX >= fromX {
            right = fromRight + (toRight - fromRight) * leadT
            left = fromLeft + (toLeft - fromLeft) * lagT
        } else {
            left = fromLeft + (toLeft - fromLeft) * leadT
            right = fromRight + (toRight - fromRight) * lagT
        }
        let height = InkStretchTabHighlight.height
        let frame = CGRect(
            x: left,
            y: rect.midY - height / 2,
            width: max(right - left, 0),
            height: height
        )
        return Path(roundedRect: frame, cornerRadius: cornerRadius)
    }
}

private struct InkTabCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGFloat] { [:] }

    static func reduce(value: inout [AnyHashable: CGFloat], nextValue: () -> [AnyHashable: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct InkBottomNavItem: View {
    let label: String
    let icon: InkTabIcon
    let isSelected: Bool
    let showLabel: Bool
    @Environment(\.inkPalette) private var palette

    private var iconSize: CGFloat { 18 }
    /// Push label below the centered icon without growing the bar layout height.
    private var labelOffsetY: CGFloat {
        iconSize / 2 + InkSpace.xxs + 6 + 4
    }

    var body: some View {
        ZStack {
            iconView
            if showLabel {
                Text(label)
                    .inkFont(size: 10, weight: .regular)
                    .lineLimit(1)
                    .offset(y: labelOffsetY)
                    .padding(.top, 4)
            }
        }
        // Unselected stays near-ink; selected uses primary (brand accent when themed).
        .foregroundStyle(isSelected ? palette.primary : palette.ink.opacity(0.78))
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: iconSize, weight: .semibold))
        case .asset(let name, let selected):
            Image(isSelected ? (selected ?? name) : name)
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
