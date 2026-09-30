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
    /// A decoration is meant to be added once. If it already has a superview, that is
    /// reported and it is removed first, which drops its existing constraints, so they never
    /// accumulate.
    func addDecoration(_ decoration: UIView, alignment: LayoutAlignment, behind: Bool) {
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
            constraints.append(decoration.leadingAnchor.constraint(equalTo: leadingAnchor))
        case .trailing, .topTrailing, .bottomTrailing:
            constraints.append(decoration.trailingAnchor.constraint(equalTo: trailingAnchor))
        case .center, .top, .bottom:
            constraints.append(decoration.centerXAnchor.constraint(equalTo: centerXAnchor))
        }
        switch alignment {
        case .fill:
            constraints += [
                decoration.topAnchor.constraint(equalTo: topAnchor),
                decoration.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        case .top, .topLeading, .topTrailing:
            constraints.append(decoration.topAnchor.constraint(equalTo: topAnchor))
        case .bottom, .bottomLeading, .bottomTrailing:
            constraints.append(decoration.bottomAnchor.constraint(equalTo: bottomAnchor))
        case .center, .leading, .trailing:
            constraints.append(decoration.centerYAnchor.constraint(equalTo: centerYAnchor))
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
