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
            stack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            axis == .vertical
                ? stack.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
                : stack.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
        ])
    }
}
