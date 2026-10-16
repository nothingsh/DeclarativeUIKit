import UIKit

/// A tap recognizer that is its own target and runs a closure.
private final class TapGesture: UITapGestureRecognizer {

    private let action: () -> Void

    init(count: Int, action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        numberOfTapsRequired = count
        addTarget(self, action: #selector(fire))
    }

    @objc func fire() {
        action()
    }
}

/// A long-press recognizer that is its own target and runs a closure once,
/// when the press begins.
private final class LongPressGesture: UILongPressGestureRecognizer {

    private let action: () -> Void

    init(minimumDuration: TimeInterval, action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        minimumPressDuration = minimumDuration
        addTarget(self, action: #selector(fire(_:)))
    }

    @objc func fire(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            action()
        }
    }
}

/// Each modifier adds a recognizer and sets `isUserInteractionEnabled`, which
/// `UILabel` and `UIImageView` leave off by default.
@MainActor
public extension UIView {

    /// Adds a tap recognizer that runs `action` when the view is tapped `count` times.
    @discardableResult
    func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> Self {
        addGestureRecognizer(TapGesture(count: count, action: action))
        isUserInteractionEnabled = true
        return self
    }

    /// Adds a long-press recognizer that runs `action` once, when the press has
    /// lasted `minimumDuration` seconds.
    @discardableResult
    func onLongPressGesture(
        minimumDuration: TimeInterval = 0.5,
        perform action: @escaping () -> Void
    ) -> Self {
        addGestureRecognizer(LongPressGesture(minimumDuration: minimumDuration, action: action))
        isUserInteractionEnabled = true
        return self
    }
}
