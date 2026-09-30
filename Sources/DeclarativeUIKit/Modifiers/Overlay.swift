import UIKit

@MainActor
public extension UIView {

    /// Puts the view that `content` returns in front of this view's current subviews.
    ///
    /// The overlay is a subview of this view, and this view's content decides its size.
    /// A later call puts its overlay further front; subviews added afterwards, such as a
    /// later arranged subview, also go in front of it. With `.fill`, the overlay's hugging
    /// and compression resistance are lowered so that its intrinsic size cannot enlarge this
    /// view; an overlay whose own subviews require a minimum size still can.
    ///
    /// Touches follow UIKit hit testing: an interactive overlay receives touches inside its
    /// bounds and blocks the content behind it. Use `.isUserInteractionEnabled(false)` to
    /// let touches through.
    @discardableResult
    func overlay(alignment: LayoutAlignment = .fill, content: () -> UIView) -> Self {
        addDecoration(content(), alignment: alignment, behind: false)
        return self
    }
}
