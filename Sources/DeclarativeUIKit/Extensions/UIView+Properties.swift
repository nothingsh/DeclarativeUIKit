import UIKit

@MainActor
public extension UIView {

    /// Runs `body` on this view, for UIKit properties without a dedicated modifier.
    @discardableResult
    func configure(_ body: (Self) -> Void) -> Self {
        body(self)
        return self
    }

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
    func accessibilityIdentifier(_ value: String?) -> Self {
        self.accessibilityIdentifier = value
        return self
    }
}
