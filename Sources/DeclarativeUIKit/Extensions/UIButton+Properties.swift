import UIKit

/// Each modifier sets the value for one `UIControl.State`, `.normal` by default.
/// States that have no value of their own fall back to `.normal`, as in UIKit.
@MainActor
public extension UIButton {

    @discardableResult
    func title(_ value: String?, for state: UIControl.State = .normal) -> Self {
        setTitle(value, for: state)
        return self
    }

    @discardableResult
    func titleColor(_ value: UIColor?, for state: UIControl.State = .normal) -> Self {
        setTitleColor(value, for: state)
        return self
    }

    @discardableResult
    func image(_ value: UIImage?, for state: UIControl.State = .normal) -> Self {
        setImage(value, for: state)
        return self
    }

    @discardableResult
    func backgroundImage(_ value: UIImage?, for state: UIControl.State = .normal) -> Self {
        setBackgroundImage(value, for: state)
        return self
    }
}
