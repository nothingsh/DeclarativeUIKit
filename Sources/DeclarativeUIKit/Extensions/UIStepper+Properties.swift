import UIKit

@MainActor
public extension UIStepper {

    /// Sets the value without sending `.valueChanged`. UIKit clamps it to the
    /// current range, so set `minimumValue` and `maximumValue` first.
    @discardableResult
    func value(_ value: Double) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    func minimumValue(_ value: Double) -> Self {
        self.minimumValue = value
        return self
    }

    @discardableResult
    func maximumValue(_ value: Double) -> Self {
        self.maximumValue = value
        return self
    }

    @discardableResult
    func stepValue(_ value: Double) -> Self {
        self.stepValue = value
        return self
    }
}
