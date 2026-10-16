import UIKit

@MainActor
public extension UIControl {

    /// Runs `action` with this control each time one of `events` fires.
    /// Each call adds another action; earlier ones stay.
    @discardableResult
    func onEvent(_ events: UIControl.Event, perform action: @escaping (Self) -> Void) -> Self {
        addAction(UIAction { action($0.sender as! Self) }, for: events)
        return self
    }
}
