import UIKit

/// A hairline across the stack it is in: horizontal in a vertical stack and vertical in a
/// horizontal stack.
///
/// It spans the stack inside its padding, whatever the stack's alignment. It is one
/// pixel thick and drawn in `.separator`; change the color with `background(_:)`. The
/// axis is read when the divider is added to a `UIStackView`, as for `Spacer`. A divider
/// outside a `UIStackView` is reported and keeps no length.
public final class Divider: UIView {

    private var axis: NSLayoutConstraint.Axis = .vertical

    public init() {
        super.init(frame: .zero)
        backgroundColor = .separator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Divider is built in code and does not support init(coder:).")
    }

    public override var intrinsicContentSize: CGSize {
        let thickness = 1 / max(traitCollection.displayScale, 1)
        return axis == .vertical
            ? CGSize(width: UIView.noIntrinsicMetric, height: thickness)
            : CGSize(width: thickness, height: UIView.noIntrinsicMetric)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateIntrinsicContentSize()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview else { return }
        guard let stack = superview as? UIStackView else {
            NSLog(
                "DeclarativeUIKit: a Divider was added to %@, which is not a UIStackView. "
                    + "A divider takes its length from a stack, so it has none here.",
                String(describing: type(of: superview))
            )
            return
        }

        axis = stack.axis
        invalidateIntrinsicContentSize()
        setContentHuggingPriority(.required, for: axis)
        setContentCompressionResistancePriority(.required, for: axis)

        // A constraint to the stack goes away when the divider leaves it. The margins
        // guide is the stack's padding when it arranges inside its margins,
        // which VStack and HStack always do.
        translatesAutoresizingMaskIntoConstraints = false
        let guide = stack.layoutMarginsGuide
        let length = axis == .vertical
            ? widthAnchor.constraint(equalTo: stack.isLayoutMarginsRelativeArrangement ? guide.widthAnchor : stack.widthAnchor)
            : heightAnchor.constraint(equalTo: stack.isLayoutMarginsRelativeArrangement ? guide.heightAnchor : stack.heightAnchor)
        length.isActive = true
    }
}
