import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    func inkKeyboardBar() -> some View {
        inkKeyboardBar { EmptyView() }
    }

    func inkKeyboardBar<Actions: View>(
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        modifier(InkKeyboardBarModifier(actions: actions))
    }
}

private struct InkKeyboardBarModifier<Actions: View>: ViewModifier {
    @ViewBuilder var actions: () -> Actions
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if keyboardHeight > 0 {
                    InkKeyboardBarContent(actions: actions)
                        .transition(.identity)
                }
            }
            #if canImport(UIKit)
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            ) { notification in
                updateKeyboardHeight(from: notification, hidden: false)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            ) { notification in
                updateKeyboardHeight(from: notification, hidden: true)
            }
            #endif
    }

    #if canImport(UIKit)
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    private func updateKeyboardHeight(from notification: Notification, hidden: Bool) {
        let userInfo = notification.userInfo
        let frame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let overlap: CGFloat
        if hidden {
            overlap = 0
        } else if let frame, let window = keyWindow {
            let converted = window.convert(frame, from: nil)
            overlap = max(0, window.bounds.maxY - converted.minY)
        } else {
            overlap = 0
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            keyboardHeight = overlap
        }
    }
    #endif
}

private struct InkKeyboardBarContent<Actions: View>: View {
    @Environment(\.inkPalette) private var palette
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: 0) {
            // Rectangle()
            //     .fill(palette.ink)
            //     .frame(height: Ink.borderWidth)

            HStack(spacing: InkSpace.sm) {
                actions()
                Spacer(minLength: 0)
                Button("Hide Keyboard", systemImage: "keyboard.chevron.compact.down") {
                    InkKeyboard.dismiss()
                }
                .inkBarIconOutlineButton()
            }
            .frame(minHeight: Ink.barButtonHeight)
            .padding(.horizontal, InkSpace.xl)
            .padding(.vertical, InkSpace.sm)
        }
        // .background(palette.paper)
    }
}
