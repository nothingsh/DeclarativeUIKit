import UIKit

@MainActor
public extension UIView {

    /// Builds an `HStack` and mounts it so it fills this view.
    ///
    /// The parameters match `HStack.init`. Mounting goes to this view's edges and
    /// applies no safe-area inset; safe-area avoidance is a separate structural
    /// modifier, composed before mounting with `addContent`.
    @discardableResult
    func addHStack(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        @UIViewBuilder content: () -> [UIView]
    ) -> HStack {
        addContent(HStack(alignment: alignment, spacing: spacing, content: content))
    }

    /// Builds a `VStack` and mounts it so it fills this view.
    ///
    /// The parameters match `VStack.init`. Mounting goes to this view's edges and
    /// applies no safe-area inset; safe-area avoidance is a separate structural
    /// modifier, composed before mounting with `addContent`.
    @discardableResult
    func addVStack(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        @UIViewBuilder content: () -> [UIView]
    ) -> VStack {
        addContent(VStack(alignment: alignment, spacing: spacing, content: content))
    }
}
