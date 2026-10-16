import UIKit

private nonisolated(unsafe) var keyboardAvoidanceKey: UInt8 = 0

@MainActor
public extension UIScrollView {

    /// Sets whether the scroll view makes room for the keyboard. Off by default.
    ///
    /// While the keyboard covers part of the scroll view, the covered height is added to
    /// the bottom content and scroll indicator insets, and the first responder inside the
    /// scroll view is scrolled into view. Insets you set yourself are kept. A keyboard
    /// that does not reach the bottom of the screen, such as a floating one on iPad,
    /// covers nothing.
    @discardableResult
    func avoidsKeyboard(_ value: Bool) -> Self {
        let current = objc_getAssociatedObject(self, &keyboardAvoidanceKey) as? KeyboardAvoidance
        if value, current == nil {
            let avoidance = KeyboardAvoidance(scrollView: self)
            objc_setAssociatedObject(self, &keyboardAvoidanceKey, avoidance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else if !value, let current {
            current.setAddedInset(0)
            objc_setAssociatedObject(self, &keyboardAvoidanceKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return self
    }
}

/// Keeps a scroll view's bottom insets in step with the keyboard.
@MainActor
final class KeyboardAvoidance: NSObject {
    private weak var scrollView: UIScrollView?
    /// The height this object has added to the bottom insets.
    private var addedInset: CGFloat = 0

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        // Hiding the keyboard also posts this notification, with a frame below the screen.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let scrollView, let screen = scrollView.window?.screen,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        var covered: CGFloat = 0
        if frame.maxY >= screen.bounds.maxY {
            let keyboard = screen.coordinateSpace.convert(frame, to: scrollView)
            covered = min(max(scrollView.bounds.maxY - keyboard.minY, 0), scrollView.bounds.height)
        }
        animate(alongside: notification) {
            self.setAddedInset(covered)
            self.scrollFirstResponderIntoView()
        }
    }

    private func animate(alongside notification: Notification, _ changes: @escaping () -> Void) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [UIView.AnimationOptions(rawValue: curve << 16), .beginFromCurrentState],
            animations: changes
        )
    }

    func setAddedInset(_ inset: CGFloat) {
        guard let scrollView else { return }
        scrollView.contentInset.bottom += inset - addedInset
        scrollView.verticalScrollIndicatorInsets.bottom += inset - addedInset
        addedInset = inset
    }

    /// Scrolls the first responder into view when it is inside the scroll view. A scroll
    /// view that is the first responder itself, such as a text view, shows its own caret.
    ///
    /// The offset is set directly, because `scrollRectToVisible` does nothing while a text
    /// field inside the scroll view is editing.
    private func scrollFirstResponderIntoView() {
        guard let scrollView, addedInset > 0,
              let responder = firstResponder(in: scrollView), responder !== scrollView
        else { return }
        let frame = responder.convert(responder.bounds, to: scrollView)
        let insets = scrollView.adjustedContentInset
        let visibleTop = scrollView.bounds.minY + insets.top
        let visibleBottom = scrollView.bounds.maxY - insets.bottom
        if frame.maxY > visibleBottom {
            scrollView.contentOffset.y += min(frame.maxY - visibleBottom, frame.minY - visibleTop)
        } else if frame.minY < visibleTop {
            scrollView.contentOffset.y -= visibleTop - frame.minY
        }
    }

    private func firstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for subview in view.subviews {
            if let responder = firstResponder(in: subview) { return responder }
        }
        return nil
    }
}
