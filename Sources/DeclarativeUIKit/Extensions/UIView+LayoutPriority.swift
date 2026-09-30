import UIKit

@MainActor
public extension UIView {

    /// Sets how strongly this view resists growing beyond its intrinsic size on `axis`.
    ///
    /// When a stack has extra space, the view with the lowest hugging priority grows.
    @discardableResult
    func contentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(priority, for: axis)
        return self
    }

    /// Sets how strongly this view resists shrinking below its intrinsic size on `axis`.
    ///
    /// When a stack runs out of space, the view with the lowest compression resistance
    /// shrinks first.
    @discardableResult
    func compressionResistancePriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
}
