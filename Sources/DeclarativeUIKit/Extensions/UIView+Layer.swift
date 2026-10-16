import UIKit

private nonisolated(unsafe) var layerColorObserverKey: UInt8 = 0

@MainActor
public extension UIView {

    /// Rounds the corners of this view's layer, all four by default.
    ///
    /// `corners` names physical corners, such as `.layerMinXMinYCorner` for the top left,
    /// so they do not mirror in right-to-left languages. It does not clip: content and
    /// subviews beyond the rounded corners stay visible. Add `clipsToBounds(true)` to cut
    /// them off, which also cuts off a shadow.
    @discardableResult
    func cornerRadius(
        _ radius: CGFloat,
        corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner],
        curve: CALayerCornerCurve = .circular
    ) -> Self {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
        layer.cornerCurve = curve
        return self
    }

    /// Draws a border inside this view's bounds, following its corner radius.
    ///
    /// A dynamic color such as `.separator` follows changes between light and dark mode.
    /// To do that, the view gets a hidden subview that resolves the color again when the
    /// appearance changes. Assigning `layer.borderColor` directly is not followed.
    @discardableResult
    func border(color: UIColor, width: CGFloat) -> Self {
        layerColorObserver.borderColor = color
        layer.borderWidth = width
        return self
    }

    /// Draws a shadow behind this view's content.
    ///
    /// A shadow is drawn outside the bounds, so it disappears with `clipsToBounds(true)`.
    /// The color follows the appearance, as for `border`. `offset` is positive toward the
    /// right and the bottom.
    @discardableResult
    func shadow(
        color: UIColor = .black,
        opacity: Float,
        radius: CGFloat,
        offset: CGSize = .zero
    ) -> Self {
        layerColorObserver.shadowColor = color
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        return self
    }
}

extension UIView {

    private var layerColorObserver: LayerColorObserver {
        if let observer = objc_getAssociatedObject(self, &layerColorObserverKey) as? LayerColorObserver {
            return observer
        }
        let observer = LayerColorObserver(target: self)
        // A visual effect view takes subviews only in its content view.
        ((self as? UIVisualEffectView)?.contentView ?? self).insertSubview(observer, at: 0)
        objc_setAssociatedObject(self, &layerColorObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
}

/// A hidden subview that writes the layer colors of the view it belongs to, resolved for
/// the current appearance, and writes them again when the appearance changes.
final class LayerColorObserver: UIView {
    private weak var target: UIView?
    var borderColor: UIColor? {
        didSet { apply() }
    }
    var shadowColor: UIColor? {
        didSet { apply() }
    }

    init(target: UIView) {
        self.target = target
        super.init(frame: .zero)
        isHidden = true
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("LayerColorObserver is built in code and does not support init(coder:).")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        apply()
    }

    private func apply() {
        guard let layer = target?.layer else { return }
        if let borderColor {
            layer.borderColor = borderColor.resolvedColor(with: traitCollection).cgColor
        }
        if let shadowColor {
            layer.shadowColor = shadowColor.resolvedColor(with: traitCollection).cgColor
        }
    }
}
