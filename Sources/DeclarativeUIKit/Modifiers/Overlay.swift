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
    /// `offset` moves the overlay from where `alignment` puts it: x is positive toward the
    /// right and y toward the bottom. It is passed to Auto Layout as it is: in a
    /// right-to-left layout a leading or trailing alignment reverses the horizontal
    /// direction, as those edges do, and the centered ones do not. Adjust the value
    /// yourself if that is not what you want. `.fill` takes no offset.
    ///
    /// Touches follow UIKit hit testing: an interactive overlay receives touches inside its
    /// bounds and blocks the content behind it. Use `.isUserInteractionEnabled(false)` to
    /// let touches through.
    @discardableResult
    func overlay(
        alignment: LayoutAlignment = .fill,
        offset: CGPoint = .zero,
        content: () -> UIView
    ) -> Self {
        addDecoration(content(), alignment: alignment, offset: offset, behind: false)
        return self
    }
}
