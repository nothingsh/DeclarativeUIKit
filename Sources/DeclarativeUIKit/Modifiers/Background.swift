import UIKit

@MainActor
public extension UIView {

    /// Sets this view's `backgroundColor`. It adds no subview.
    ///
    /// A stack does not draw its `backgroundColor` on iOS 13. To support iOS 13, give a
    /// stack a colored view with `background(alignment:content:)` instead.
    @discardableResult
    func background(_ color: UIColor?) -> Self {
        backgroundColor = color
        return self
    }
}

@MainActor
public extension UIStackView {

    /// Puts the view that `content` returns behind the stack's content, covering the whole
    /// stack including its padding by default.
    ///
    /// The decoration is a subview of the stack, not an arranged subview, so it takes no
    /// part in the stack's arrangement and the stack's content decides its size. A later
    /// call puts its decoration further back. With `.fill`, the decoration's hugging and
    /// compression resistance are lowered so that its intrinsic size cannot enlarge the
    /// stack; a decoration whose own subviews require a minimum size still can.
    @discardableResult
    func background(alignment: LayoutAlignment = .fill, content: () -> UIView) -> Self {
        addDecoration(content(), alignment: alignment, behind: true)
        return self
    }
}
