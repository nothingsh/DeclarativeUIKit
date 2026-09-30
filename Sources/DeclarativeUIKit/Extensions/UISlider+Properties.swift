import UIKit

@MainActor
public extension UISlider {

    /// Sets the value without sending `.valueChanged`. UIKit clamps it to the
    /// current range, so set `minimumValue` and `maximumValue` first.
    @discardableResult
    func value(_ value: Float) -> Self {
        self.value = value
        return self
    }

    @discardableResult
    func minimumValue(_ value: Float) -> Self {
        self.minimumValue = value
        return self
    }

    @discardableResult
    func maximumValue(_ value: Float) -> Self {
        self.maximumValue = value
        return self
    }

    @discardableResult
    func minimumTrackTintColor(_ value: UIColor?) -> Self {
        self.minimumTrackTintColor = value
        return self
    }

    @discardableResult
    func maximumTrackTintColor(_ value: UIColor?) -> Self {
        self.maximumTrackTintColor = value
        return self
    }
}
