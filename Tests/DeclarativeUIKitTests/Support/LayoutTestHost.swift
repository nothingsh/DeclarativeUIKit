import UIKit

/// A main-thread UIKit hierarchy with explicit geometry for layout assertions.
/// Each test owns its window; no global key window is read or replaced.
@MainActor
final class LayoutTestHost {
    private let window: UIWindow
    private let viewController: UIViewController

    var rootView: UIView { viewController.view }

    init(size: CGSize, additionalSafeAreaInsets: UIEdgeInsets = .zero) {
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        viewController = UIViewController()
        viewController.additionalSafeAreaInsets = additionalSafeAreaInsets
        window.rootViewController = viewController
        window.isHidden = false
        layout()
    }

    func layout() {
        window.setNeedsLayout()
        rootView.setNeedsLayout()
        window.layoutIfNeeded()
        rootView.layoutIfNeeded()
    }

    func resize(to size: CGSize) {
        window.frame = CGRect(origin: .zero, size: size)
        layout()
    }

    func setAdditionalSafeAreaInsets(_ insets: UIEdgeInsets) {
        viewController.additionalSafeAreaInsets = insets
        layout()
    }
}
