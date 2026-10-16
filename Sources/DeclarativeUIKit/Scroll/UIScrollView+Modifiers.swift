import UIKit

@MainActor
public extension UIScrollView {

    @discardableResult
    func bounces(_ value: Bool) -> Self {
        self.bounces = value
        return self
    }

    @discardableResult
    func alwaysBounceHorizontal(_ value: Bool) -> Self {
        self.alwaysBounceHorizontal = value
        return self
    }

    @discardableResult
    func alwaysBounceVertical(_ value: Bool) -> Self {
        self.alwaysBounceVertical = value
        return self
    }

    @discardableResult
    func isPagingEnabled(_ value: Bool) -> Self {
        self.isPagingEnabled = value
        return self
    }

    @discardableResult
    func keyboardDismissMode(_ value: UIScrollView.KeyboardDismissMode) -> Self {
        self.keyboardDismissMode = value
        return self
    }

    @discardableResult
    func contentInsetAdjustmentBehavior(_ value: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        self.contentInsetAdjustmentBehavior = value
        return self
    }
}

@MainActor
extension UIScrollView {

    /// Adds `stack` as the scrolled content. Its edges set the content size, and on the
    /// axis that does not scroll it matches the scroll view's own length.
    func mount(_ stack: UIStackView, scrolling axis: NSLayoutConstraint.Axis) {
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor).named("scrollContent.leading"),
            stack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).named("scrollContent.trailing"),
            stack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).named("scrollContent.top"),
            stack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor).named("scrollContent.bottom"),
            axis == .vertical
                ? stack.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor).named("scrollContent.width")
                : stack.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor).named("scrollContent.height")
        ])
    }
}
