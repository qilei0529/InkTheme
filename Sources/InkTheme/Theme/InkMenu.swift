import SwiftUI
import UIKit

// MARK: - Row

public struct InkMenuRow: View {
    let title: String
    var systemImage: String?
    var isSelected: Bool
    var action: () -> Void

    @Environment(\.inkPalette) private var palette

    public init(
        _ title: String,
        systemImage: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: InkSpace.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 20, alignment: .center)
                }
                Text(title)
                    .inkText(.bodyStrong, size: .md)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(palette.primary)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(!isSelected)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(isSelected ? palette.foreground : palette.foreground.opacity(0.55))
            .padding(.horizontal, InkSpace.md)
            .frame(minHeight: Ink.barButtonHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Menu

public struct InkMenu<Label: View, Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var label: () -> Label
    @ViewBuilder var content: () -> Content

    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var anchorGlobal: CGRect = .zero

    public init(
        isPresented: Binding<Bool>,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.label = label
        self.content = content
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 4) {
                label()
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(palette.foreground)
            .padding(.horizontal, 10)
            .frame(minHeight: Ink.barButtonHeight)
            .background {
                RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                    .fill(palette.panel)
                    .overlay {
                        RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                            .stroke(
                                isPresented ? palette.primary : palette.border,
                                lineWidth: Ink.borderWidth
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .background {
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: InkMenuAnchorKey.self,
                        value: geo.frame(in: .global)
                    )
            }
        }
        .onPreferenceChange(InkMenuAnchorKey.self) { anchorGlobal = $0 }
        .background {
            InkMenuPortal(
                isPresented: isPresented,
                anchor: anchorGlobal,
                palette: palette,
                radius: inkRadius,
                reduceMotion: reduceMotion,
                onDismiss: { isPresented = false },
                panel: AnyView(
                    InkMenuPanel(content: content)
                        .environment(\.inkPalette, palette)
                        .environment(\.inkRadius, inkRadius)
                )
            )
        }
    }
}

// MARK: - Picker

public struct InkMenuPicker<Selection: Hashable, Label: View>: View {
    @Binding var selection: Selection
    @Binding var isPresented: Bool
    var options: [Selection]
    var title: (Selection) -> String
    var systemImage: ((Selection) -> String?)?
    @ViewBuilder var label: (Selection) -> Label

    public init(
        selection: Binding<Selection>,
        isPresented: Binding<Bool>,
        options: [Selection],
        title: @escaping (Selection) -> String,
        systemImage: ((Selection) -> String?)? = nil,
        @ViewBuilder label: @escaping (Selection) -> Label
    ) {
        self._selection = selection
        self._isPresented = isPresented
        self.options = options
        self.title = title
        self.systemImage = systemImage
        self.label = label
    }

    public init(
        selection: Binding<Selection>,
        isPresented: Binding<Bool>,
        options: [Selection],
        title keyPath: KeyPath<Selection, String>,
        systemImage systemImageKeyPath: KeyPath<Selection, String>? = nil,
        @ViewBuilder label: @escaping (Selection) -> Label
    ) {
        self.init(
            selection: selection,
            isPresented: isPresented,
            options: options,
            title: { $0[keyPath: keyPath] },
            systemImage: systemImageKeyPath.map { path in { Optional($0[keyPath: path]) } },
            label: label
        )
    }

    public var body: some View {
        InkMenu(isPresented: $isPresented) {
            label(selection)
        } content: {
            ForEach(options, id: \.self) { option in
                InkMenuRow(
                    title(option),
                    systemImage: systemImage?(option),
                    isSelected: selection == option
                ) {
                    selection = option
                    isPresented = false
                }
            }
        }
    }
}

public struct InkMenuPickerTitle: View {
    let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .inkText(.caption, size: .xxs)
            .lineLimit(1)
    }
}

extension InkMenuPicker where Label == InkMenuPickerTitle {
    public init(
        selection: Binding<Selection>,
        isPresented: Binding<Bool>,
        options: [Selection],
        title keyPath: KeyPath<Selection, String>,
        systemImage systemImageKeyPath: KeyPath<Selection, String>? = nil
    ) {
        self.init(
            selection: selection,
            isPresented: isPresented,
            options: options,
            title: keyPath,
            systemImage: systemImageKeyPath
        ) { option in
            InkMenuPickerTitle(option[keyPath: keyPath])
        }
    }
}

// MARK: - Anchor / panel

private struct InkMenuAnchorKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct InkMenuPanel<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, InkSpace.xxs)
        .frame(minWidth: 148, maxWidth: .infinity, alignment: .leading)
        .background(palette.panel)
        .clipShape(RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: inkRadius.button, style: .continuous)
                .strokeBorder(palette.border, lineWidth: Ink.borderWidth)
        }
    }
}

// MARK: - Window portal (anchored dropdown, no sheet / no mask)

/// Transparent window overlay: tap-anywhere dismiss + panel under the trigger.
private struct InkMenuPortal: UIViewRepresentable {
    var isPresented: Bool
    var anchor: CGRect
    var palette: InkPalette
    var radius: InkRadius
    var reduceMotion: Bool
    var onDismiss: () -> Void
    var panel: AnyView

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.sync(
            isPresented: isPresented,
            anchor: anchor,
            reduceMotion: reduceMotion,
            onDismiss: onDismiss,
            panel: panel,
            from: uiView
        )
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.hide()
    }

    @MainActor
    final class Coordinator: NSObject {
        private var dismissControl: UIControl?
        private var panelHost: UIHostingController<AnyView>?
        private var onDismiss: (() -> Void)?
        private var didAnimateIn = false

        func sync(
            isPresented: Bool,
            anchor: CGRect,
            reduceMotion: Bool,
            onDismiss: @escaping () -> Void,
            panel: AnyView,
            from anchorView: UIView
        ) {
            self.onDismiss = onDismiss

            guard isPresented, !anchor.isEmpty else {
                hide()
                return
            }

            guard let window = anchorView.window ?? Self.keyWindow() else {
                hide()
                return
            }

            let isNew = dismissControl == nil

            if dismissControl == nil {
                let control = UIControl(frame: window.bounds)
                control.backgroundColor = .clear
                control.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                control.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
                control.accessibilityLabel = "Dismiss menu"
                window.addSubview(control)
                dismissControl = control
            } else {
                dismissControl?.frame = window.bounds
                if dismissControl?.superview !== window {
                    window.addSubview(dismissControl!)
                }
            }

            let hosting: UIHostingController<AnyView>
            if let panelHost {
                hosting = panelHost
                hosting.rootView = panel
            } else {
                hosting = UIHostingController(rootView: panel)
                hosting.view.backgroundColor = .clear
                hosting.safeAreaRegions = []
                panelHost = hosting
            }

            // Pass 1: compressed width so rows hug labels (not the old 280pt proposal).
            // Pass 2: lay out at max(content, trigger, 148), capped to the screen.
            let margin = InkSpace.sm
            let maxWidth = max(148, window.bounds.width - margin * 2)
            let compressed = hosting.sizeThatFits(
                in: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
            )
            let targetWidth = min(
                max(max(compressed.width, 148), anchor.width),
                maxWidth
            )
            let size = hosting.sizeThatFits(
                in: CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude)
            )
            let fitted = CGSize(width: targetWidth, height: max(size.height, compressed.height))
            let frame = Self.panelFrame(size: fitted, anchor: anchor, in: window.bounds)
            hosting.view.frame = frame

            if hosting.view.superview !== window {
                window.addSubview(hosting.view)
            }
            window.bringSubviewToFront(dismissControl!)
            window.bringSubviewToFront(hosting.view)

            if isNew, !reduceMotion, !didAnimateIn {
                didAnimateIn = true
                hosting.view.alpha = 0
                hosting.view.transform = CGAffineTransform(translationX: 0, y: 6)
                UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
                    hosting.view.alpha = 1
                    hosting.view.transform = .identity
                }
            } else {
                hosting.view.alpha = 1
                hosting.view.transform = .identity
            }
        }

        func hide() {
            dismissControl?.removeFromSuperview()
            dismissControl = nil
            panelHost?.view.removeFromSuperview()
            panelHost = nil
            onDismiss = nil
            didAnimateIn = false
        }

        @objc private func handleDismiss() {
            onDismiss?()
        }

        private static func panelFrame(size: CGSize, anchor: CGRect, in bounds: CGRect) -> CGRect {
            let gap = InkSpace.xxs
            let margin = InkSpace.sm
            let width = size.width
            let height = max(size.height, Ink.barButtonHeight)

            var x = anchor.minX
            var y = anchor.maxY + gap

            x = min(max(margin, x), max(margin, bounds.width - width - margin))

            if y + height + margin > bounds.height {
                y = anchor.minY - gap - height
            }
            y = min(max(margin, y), max(margin, bounds.height - height - margin))

            return CGRect(x: x, y: y, width: width, height: height)
        }

        private static func keyWindow() -> UIWindow? {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                if let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return key
                }
            }
            return nil
        }
    }
}
