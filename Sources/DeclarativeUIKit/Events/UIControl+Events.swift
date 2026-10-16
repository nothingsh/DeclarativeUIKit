import UIKit

/// Carries `onEvent` so that `Self` is the concrete control type in its closure.
/// Every `UIControl` conforms; do not conform other types.
public protocol ControlEventHandling: UIControl {}

extension UIControl: ControlEventHandling {}

@MainActor
public extension ControlEventHandling {

    /// Runs `action` with this control each time one of `events` fires.
    /// Each call adds another action; earlier ones stay.
    @discardableResult
    func onEvent(_ events: UIControl.Event, perform action: @escaping (Self) -> Void) -> Self {
        addAction(UIAction { action($0.sender as! Self) }, for: events)
        return self
    }
}
