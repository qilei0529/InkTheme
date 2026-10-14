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
    @Environment(\.inkPalette) private var palette

    public init(items: [InkTabItem<ID>], selection: Binding<ID>) {
        self.items = items
        _selection = selection
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
                        isSelected: selection == item.id
                    )
                }
                .buttonStyle(InkBottomNavButtonStyle())
            }
        }
        .padding(.top, InkSpace.sm)
        .background {
            palette.paper
                .ignoresSafeArea(edges: .bottom)
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
    @Environment(\.inkPalette) private var palette

    var body: some View {
        VStack(spacing: InkSpace.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .regular))
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
