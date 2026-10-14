import UIKit

@MainActor
public extension UISegmentedControl {

    /// Selects a segment without sending `.valueChanged`. Use
    /// `UISegmentedControl.noSegment` to select none.
    @discardableResult
    func selectedSegmentIndex(_ value: Int) -> Self {
        self.selectedSegmentIndex = value
        return self
    }

    @discardableResult
    func selectedSegmentTintColor(_ value: UIColor?) -> Self {
        self.selectedSegmentTintColor = value
        return self
    }

    /// A momentary control does not keep a segment selected after it is tapped.
    @discardableResult
    func isMomentary(_ value: Bool) -> Self {
        self.isMomentary = value
        return self
    }
}
