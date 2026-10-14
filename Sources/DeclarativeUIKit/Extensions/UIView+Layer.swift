import UIKit

@MainActor
public extension UIView {

    /// Rounds the corners of this view's layer.
    ///
    /// It does not clip: content and subviews beyond the rounded corners stay visible.
    /// Add `clipsToBounds(true)` to cut them off, which also cuts off a shadow.
    @discardableResult
    func cornerRadius(_ radius: CGFloat, curve: CALayerCornerCurve = .circular) -> Self {
        layer.cornerRadius = radius
        layer.cornerCurve = curve
        return self
    }

    /// Draws a border inside this view's bounds, following its corner radius.
    ///
    /// The layer takes a `CGColor`, so the color is resolved once, when this is called. A
    /// dynamic color such as `.separator` keeps that appearance and does not follow a later
    /// change between light and dark mode.
    @discardableResult
    func border(color: UIColor, width: CGFloat) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }

    /// Draws a shadow behind this view's content.
    ///
    /// A shadow is drawn outside the bounds, so it disappears with `clipsToBounds(true)`.
    /// The color is resolved once, as for `border`. `offset` is positive toward the right
    /// and the bottom.
    @discardableResult
    func shadow(
        color: UIColor = .black,
        opacity: Float,
        radius: CGFloat,
        offset: CGSize = .zero
    ) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        return self
    }
}
