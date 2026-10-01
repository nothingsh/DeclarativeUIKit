import UIKit

/// An empty view that takes the remaining length along the axis of the stack it is in.
///
/// A spacer gives way before any view with content: its hugging on the stack's axis is the
/// lowest, so it absorbs the extra space, and it never grows on the cross axis. Several
/// spacers in one stack share the extra space equally. `minLength` is kept as a required
/// minimum; when the stack cannot fit it, the other views shrink according to their
/// compression resistance. Along an unbounded axis, such as the scrolling axis of a scroll
/// view, there is no remaining length, so a spacer is only `minLength` long.
///
/// The axis is read when the spacer is added to a `UIStackView`. Changing that stack's
/// `axis` afterwards is not followed. A spacer outside a `UIStackView` has no effect, and
/// adding it to one is reported.
public final class Spacer: UIView {

    /// The length the spacer keeps at least, along the stack's axis.
    public let minLength: CGFloat

    public init(minLength: CGFloat = 0) {
        precondition(
            minLength.isFinite && minLength >= 0,
            "Spacer minLength must be finite and not negative."
        )
        self.minLength = minLength
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Spacer is built in code and does not support init(coder:).")
    }

    public override var intrinsicContentSize: CGSize { .zero }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview else { return }
        guard let stack = superview as? UIStackView else {
            NSLog(
                "DeclarativeUIKit: a Spacer was added to %@, which is not a UIStackView. "
                    + "A spacer only takes space inside a stack, so it has no effect here.",
                String(describing: type(of: superview))
            )
            return
        }

        let identifier = "DeclarativeUIKit.spacer.minLength"
        constraints.first { $0.identifier == identifier }?.isActive = false

        let axis = stack.axis
        let crossAxis: NSLayoutConstraint.Axis = axis == .horizontal ? .vertical : .horizontal
        setContentHuggingPriority(.fittingSizeLevel, for: axis)
        setContentHuggingPriority(.defaultLow, for: crossAxis)

        translatesAutoresizingMaskIntoConstraints = false
        let minimum = length(axis).constraint(greaterThanOrEqualToConstant: minLength)
        minimum.identifier = identifier
        minimum.isActive = true

        // Below the default hugging of views with content, so sharing the extra space
        // equally never stretches them. Tied to every other spacer, so the rest go on
        // sharing equally when one of them leaves the stack.
        for case let other as Spacer in stack.subviews where other !== self {
            let equal = length(axis).constraint(equalTo: other.length(axis))
            equal.priority = .defaultLow - 1
            equal.isActive = true
        }
    }

    private func length(_ axis: NSLayoutConstraint.Axis) -> NSLayoutDimension {
        axis == .horizontal ? widthAnchor : heightAnchor
    }
}
