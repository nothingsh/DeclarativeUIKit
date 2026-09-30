import UIKit

@MainActor
public extension UIControl {

    @discardableResult
    func isEnabled(_ value: Bool) -> Self {
        self.isEnabled = value
        return self
    }

    @discardableResult
    func isSelected(_ value: Bool) -> Self {
        self.isSelected = value
        return self
    }

    @discardableResult
    func isHighlighted(_ value: Bool) -> Self {
        self.isHighlighted = value
        return self
    }
}
