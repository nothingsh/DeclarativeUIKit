import UIKit

@MainActor
public extension UIView {

    /// Makes VoiceOver read this view and its descendants as one element. Its label joins
    /// the labels of the visible descendants in order, and follows later changes to them.
    ///
    /// Only labels are combined, not traits or actions, so do not combine an area that
    /// holds buttons or other controls. This sets `accessibilityElements`.
    @discardableResult
    func accessibilityCombined() -> Self {
        isAccessibilityElement = false
        accessibilityElements = [CombinedAccessibilityElement(accessibilityContainer: self)]
        return self
    }
}

/// An accessibility element that covers its container and reads its label from the
/// container's descendants each time it is asked.
final class CombinedAccessibilityElement: UIAccessibilityElement {

    override var accessibilityLabel: String? {
        get {
            guard let container = accessibilityContainer as? UIView else { return nil }
            return Self.labels(in: container).joined(separator: ", ")
        }
        set {}
    }

    override var accessibilityFrameInContainerSpace: CGRect {
        get { (accessibilityContainer as? UIView)?.bounds ?? .zero }
        set {}
    }

    /// The first non-empty label on each path down from `view`, depth first. A label's
    /// text counts as its accessibility label, which UIKit reports only while an
    /// assistive technology is running.
    private static func labels(in view: UIView) -> [String] {
        view.subviews.filter { !$0.isHidden }.flatMap { subview -> [String] in
            if let label = subview.accessibilityLabel ?? (subview as? UILabel)?.text, !label.isEmpty {
                return [label]
            }
            return labels(in: subview)
        }
    }
}
