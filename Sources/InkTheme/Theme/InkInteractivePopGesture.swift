import SwiftUI

#if canImport(UIKit)
import UIKit

/// Re-enables UIKit’s left-edge swipe-to-pop when the system navigation bar is hidden
/// (`.toolbar(.hidden, for: .navigationBar)` otherwise disables it).
public struct InkInteractivePopGestureInstaller: UIViewControllerRepresentable {
    public init() {}

    public func makeUIViewController(context: Context) -> InkInteractivePopGestureController {
        InkInteractivePopGestureController()
    }

    public func updateUIViewController(
        _ uiViewController: InkInteractivePopGestureController,
        context: Context
    ) {}
}

public final class InkInteractivePopGestureController: UIViewController, UIGestureRecognizerDelegate {
    private weak var nav: UINavigationController?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let navigationController else { return }
        nav = navigationController
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (nav?.viewControllers.count ?? 0) > 1
    }
}

extension View {
    /// Keep the system left-edge swipe-back while using a custom / hidden nav bar.
    /// Attach once on the `NavigationStack` root content.
    public func inkInteractivePopGesture() -> some View {
        background(InkInteractivePopGestureInstaller())
    }
}
#else
extension View {
    public func inkInteractivePopGesture() -> some View { self }
}
#endif
