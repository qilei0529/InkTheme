import SwiftUI

public struct InkDialog<Actions: View, Footer: View, Content: View>: View {
    let title: String
    @Environment(\.inkPalette) private var palette
    @Environment(\.inkRadius) private var inkRadius
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var footer: () -> Footer
    @ViewBuilder var content: () -> Content

    public init(
        title: String,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.actions = actions
        self.footer = footer
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: InkSpace.sm) {
            header
            content()
            footer()
        }
        .padding(InkSpace.xl)
        .frame(maxWidth: Ink.dialogMaxWidth, alignment: .leading)
        .inkDismissKeyboardOnTap()
        .background(palette.paper)
        .clipShape(RoundedRectangle(cornerRadius: inkRadius.dialog, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: inkRadius.dialog, style: .continuous)
                .strokeBorder(palette.ink, lineWidth: Ink.borderWidth)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: InkSpace.sm) {
            Text(title)
                .inkText(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)

            actions()
        }
    }
}

extension InkDialog where Actions == EmptyView, Footer == EmptyView {
    public init(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            actions: { EmptyView() },
            footer: { EmptyView() },
            content: content
        )
    }
}

extension InkDialog where Footer == EmptyView {
    public init(
        title: String,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            actions: actions,
            footer: { EmptyView() },
            content: content
        )
    }
}

public struct InkDialogFooter<Content: View>: View {
    @ViewBuilder var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: InkSpace.md) {
            content()
        }
        .padding(.top, InkSpace.sm)
        .frame(maxWidth: .infinity)
    }
}

public struct InkAlert: View {
    let title: String
    var message: String?
    let primaryTitle: String
    var secondaryTitle: String?
    var primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    public init(
        title: String,
        message: String? = nil,
        primaryTitle: String,
        secondaryTitle: String? = nil,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        InkDialog(
            title: title,
            actions: { EmptyView() },
            footer: {
                InkDialogFooter {
                    Button(primaryTitle, action: primaryAction)
                        .inkFillButton()
                    if let secondaryTitle {
                        Button(secondaryTitle, action: { secondaryAction?() })
                            .inkOutlineButton()
                    }
                }
            },
            content: {
                if let message {
                    Text(message)
                        .inkText(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        )
    }
}

extension View {
    public func inkDialog<Dialog: View>(
        isPresented: Binding<Bool>,
        dismissOnBackdrop: Bool = true,
        @ViewBuilder dialog: @escaping () -> Dialog
    ) -> some View {
        modifier(
            InkDialogOverlayModifier(
                isPresented: isPresented,
                dismissOnBackdrop: dismissOnBackdrop,
                dialog: dialog
            )
        )
    }

    public func inkAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        primary: String,
        secondary: String? = nil,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        inkDialog(isPresented: isPresented, dismissOnBackdrop: false) {
            InkAlert(
                title: title,
                message: message,
                primaryTitle: primary,
                secondaryTitle: secondary,
                primaryAction: {
                    primaryAction()
                    isPresented.wrappedValue = false
                },
                secondaryAction: secondary.map { _ in
                    {
                        secondaryAction?()
                        isPresented.wrappedValue = false
                    }
                }
            )
        }
    }
}

private struct InkDialogOverlayModifier<Dialog: View>: ViewModifier {
    @Binding var isPresented: Bool
    var dismissOnBackdrop: Bool
    @ViewBuilder var dialog: () -> Dialog
    @Environment(\.inkPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if isPresented {
                        palette.ink
                            .opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture {
                                guard dismissOnBackdrop else { return }
                                dismiss()
                            }
                            .accessibilityHidden(true)

                        dialog()
                            .padding(.horizontal, Ink.sheetScreenInset)
                            .transition(
                                reduceMotion
                                    ? .identity
                                    : .asymmetric(
                                        insertion: .offset(y: Ink.dialogMoveInOffset),
                                        removal: .identity
                                    )
                            )
                            .accessibilityAddTraits(.isModal)
                    }
                }
                .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: isPresented)
                .allowsHitTesting(isPresented)
            }
    }

    private func dismiss() {
        isPresented = false
    }
}
