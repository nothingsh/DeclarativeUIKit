import UIKit

@MainActor
public extension UISwitch {

    /// Sets the state without animation and without sending `.valueChanged`.
    @discardableResult
    func isOn(_ value: Bool) -> Self {
        self.isOn = value
        return self
    }

    @discardableResult
    func onTintColor(_ value: UIColor?) -> Self {
        self.onTintColor = value
        return self
    }
}
