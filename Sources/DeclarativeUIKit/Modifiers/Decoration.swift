import UIKit

/// Where a decoration sits inside the view it decorates.
///
/// `fill` stretches the decoration over the whole view. Every other case keeps the
/// decoration's own size and places it at that position. `leading` and `trailing`
/// follow the layout direction, so they mirror in right-to-left languages.
public enum LayoutAlignment: Sendable {
    case fill
    case center
    case top
    case bottom
    case leading
    case trailing
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

@MainActor
extension UIView {

    /// Adds `decoration` as a subview behind or in front of the existing subviews and
    /// constrains it to this view according to `alignment`.
    ///
    /// A `fill` decoration gets the lowest hugging and compression resistance, so its own
    /// intrinsic size cannot enlarge this view.
    ///
    /// `offset` moves the decoration from where `alignment` puts it, without resizing
    /// anything. It is the constant of the alignment constraints and nothing more: x is
    /// positive toward the right and y toward the bottom, and the layout direction is left
    /// to Auto Layout. A `fill` decoration covers the whole view, so an offset for it is a
    /// programming error.
    ///
    /// A decoration is meant to be added once. If it already has a superview, that is
    /// reported and it is removed first, which drops its existing constraints, so they never
    /// accumulate.
    func addDecoration(_ decoration: UIView, alignment: LayoutAlignment, offset: CGPoint, behind: Bool) {
        precondition(
            alignment != .fill || offset == .zero,
            "A fill decoration covers the whole view and takes no offset."
        )
        if decoration.superview != nil {
            NSLog(
                "DeclarativeUIKit: a background or overlay received %@, which already has a "
                    + "superview. A decoration should be added once. It is being removed from "
                    + "its current parent, dropping its existing constraints, and added again.",
                String(describing: type(of: decoration))
            )
            decoration.removeFromSuperview()
        }
        if behind {
            insertSubview(decoration, at: 0)
        } else {
            addSubview(decoration)
        }
        decoration.translatesAutoresizingMaskIntoConstraints = false

        var constraints: [NSLayoutConstraint] = []
        switch alignment {
        case .fill:
            constraints += [
                decoration.leadingAnchor.constraint(equalTo: leadingAnchor),
                decoration.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        case .leading, .topLeading, .bottomLeading:
            constraints.append(decoration.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset.x))
        case .trailing, .topTrailing, .bottomTrailing:
            constraints.append(decoration.trailingAnchor.constraint(equalTo: trailingAnchor, constant: offset.x))
        case .center, .top, .bottom:
            constraints.append(decoration.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x))
        }
        switch alignment {
        case .fill:
            constraints += [
                decoration.topAnchor.constraint(equalTo: topAnchor),
                decoration.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        case .top, .topLeading, .topTrailing:
            constraints.append(decoration.topAnchor.constraint(equalTo: topAnchor, constant: offset.y))
        case .bottom, .bottomLeading, .bottomTrailing:
            constraints.append(decoration.bottomAnchor.constraint(equalTo: bottomAnchor, constant: offset.y))
        case .center, .leading, .trailing:
            constraints.append(decoration.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y))
        }
        NSLayoutConstraint.activate(constraints)

        if alignment == .fill {
            for axis in [NSLayoutConstraint.Axis.horizontal, .vertical] {
                decoration.setContentHuggingPriority(.fittingSizeLevel, for: axis)
                decoration.setContentCompressionResistancePriority(.fittingSizeLevel, for: axis)
            }
        }
    }
}
