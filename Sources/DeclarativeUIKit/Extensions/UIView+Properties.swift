import UIKit

/// Provides `configure` to every view.
///
/// In a protocol extension `Self` is the caller's concrete type, so the closure receives a
/// subclass with its own members. Swift 6.1 and earlier do not give a class extension's
/// `(Self) -> Void` parameter that type.
@_documentation(visibility: internal)
public protocol Configurable: AnyObject {}

public extension Configurable {

    /// Runs `body` on this view, for UIKit properties without a dedicated modifier.
    @discardableResult
    func configure(_ body: (Self) -> Void) -> Self {
        body(self)
        return self
    }
}

extension UIView: Configurable {}

@MainActor
public extension UIView {

    @discardableResult
    func alpha(_ value: CGFloat) -> Self {
        self.alpha = value
        return self
    }

    @discardableResult
    func isHidden(_ value: Bool) -> Self {
        self.isHidden = value
        return self
    }

    @discardableResult
    func isUserInteractionEnabled(_ value: Bool) -> Self {
        self.isUserInteractionEnabled = value
        return self
    }

    @discardableResult
    func contentMode(_ value: UIView.ContentMode) -> Self {
        self.contentMode = value
        return self
    }

    @discardableResult
    func tintColor(_ value: UIColor?) -> Self {
        self.tintColor = value
        return self
    }

    @discardableResult
    func clipsToBounds(_ value: Bool) -> Self {
        self.clipsToBounds = value
        return self
    }

    @discardableResult
    func accessibilityLabel(_ value: String?) -> Self {
        self.accessibilityLabel = value
        return self
    }

    @discardableResult
    func accessibilityHint(_ value: String?) -> Self {
        self.accessibilityHint = value
        return self
    }

    @discardableResult
    func accessibilityTraits(_ value: UIAccessibilityTraits) -> Self {
        self.accessibilityTraits = value
        return self
    }

    @discardableResult
    func isAccessibilityElement(_ value: Bool) -> Self {
        self.isAccessibilityElement = value
        return self
    }

    @discardableResult
    func accessibilityIdentifier(_ value: String?) -> Self {
        self.accessibilityIdentifier = value
        return self
    }
}
