import UIKit

@MainActor
public extension UIView {

    /// Gives this view a fixed width, height, or both, as required constraints.
    ///
    /// Each named axis is redefined: a repeated call updates the constant, and a
    /// minimum or maximum set earlier on that axis is removed. A `nil` axis is left
    /// as it is.
    @discardableResult
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        if let width { setFixedSize(.width, width) }
        if let height { setFixedSize(.height, height) }
        return self
    }

    /// Limits this view's width, height, or both to a range, as required constraints.
    ///
    /// An axis is redefined when either of its bounds is given: the given bounds are
    /// set or updated, the other bound and a fixed length set earlier on that axis are
    /// removed. `.infinity` as a maximum means no upper bound and adds no constraint.
    @discardableResult
    func frame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        if minWidth != nil || maxWidth != nil { setSizeRange(.width, minWidth, maxWidth) }
        if minHeight != nil || maxHeight != nil { setSizeRange(.height, minHeight, maxHeight) }
        return self
    }

    /// Keeps this view's width equal to `ratio` times its height, as a required constraint.
    ///
    /// A repeated call replaces the earlier ratio, and `nil` removes it. Combine it with a
    /// fixed width or height to derive the other length; fixing both as well conflicts.
    @discardableResult
    func frame(aspectRatio ratio: CGFloat?) -> Self {
        precondition(
            ratio == nil || (ratio!.isFinite && ratio! > 0),
            "frame aspect ratio must be finite and greater than 0."
        )
        translatesAutoresizingMaskIntoConstraints = false
        let identifier = "DeclarativeUIKit.aspectRatio"
        constraints.first { $0.identifier == identifier }?.isActive = false

        if let ratio {
            // The multiplier cannot change after creation, so a new ratio is a new constraint.
            let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio)
            constraint.identifier = identifier
            constraint.isActive = true
        }
        return self
    }
}

private enum SizeAxis: String {
    case width
    case height
}

private enum SizeBound: String {
    case fixed
    case min
    case max
}

@MainActor
private extension UIView {

    func setFixedSize(_ axis: SizeAxis, _ length: CGFloat) {
        precondition(
            length.isFinite && length >= 0,
            "frame \(axis.rawValue) must be finite and not negative."
        )
        setSizeConstraint(axis, .fixed, length)
        setSizeConstraint(axis, .min, nil)
        setSizeConstraint(axis, .max, nil)
    }

    func setSizeRange(_ axis: SizeAxis, _ min: CGFloat?, _ max: CGFloat?) {
        precondition(
            min == nil || (min!.isFinite && min! >= 0),
            "frame minimum \(axis.rawValue) must be finite and not negative."
        )
        precondition(
            max == nil || max! >= 0,
            "frame maximum \(axis.rawValue) must not be negative or NaN; use .infinity for no limit."
        )
        precondition(
            min == nil || max == nil || min! <= max!,
            "frame minimum \(axis.rawValue) must not exceed the maximum."
        )
        setSizeConstraint(axis, .fixed, nil)
        setSizeConstraint(axis, .min, min)
        setSizeConstraint(axis, .max, max?.isFinite == true ? max : nil)
    }

    /// Updates the library's constraint for `axis` and `bound`, creating it if needed.
    /// A `nil` length removes it. Constraints the library did not create are untouched.
    func setSizeConstraint(_ axis: SizeAxis, _ bound: SizeBound, _ length: CGFloat?) {
        let identifier = "DeclarativeUIKit.\(axis.rawValue).\(bound.rawValue)"
        let existing = constraints.first { $0.identifier == identifier }

        guard let length else {
            existing?.isActive = false
            return
        }
        if let existing {
            existing.constant = length
            return
        }

        let dimension = axis == .width ? widthAnchor : heightAnchor
        let constraint: NSLayoutConstraint
        switch bound {
        case .fixed: constraint = dimension.constraint(equalToConstant: length)
        case .min: constraint = dimension.constraint(greaterThanOrEqualToConstant: length)
        case .max: constraint = dimension.constraint(lessThanOrEqualToConstant: length)
        }
        constraint.identifier = identifier
        constraint.isActive = true
    }
}
