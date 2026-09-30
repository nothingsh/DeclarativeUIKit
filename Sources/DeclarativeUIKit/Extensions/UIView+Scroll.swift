import UIKit

@MainActor
public extension UIView {

    /// Builds an `HScroll` and mounts it so it fills this view.
    ///
    /// The parameters match `HScroll.init`. Mounting goes to this view's edges and
    /// applies no safe-area inset.
    @discardableResult
    func addHScroll(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @UIViewBuilder content: () -> [UIView]
    ) -> HScroll {
        addContent(HScroll(
            alignment: alignment,
            spacing: spacing,
            showsIndicators: showsIndicators,
            content: content
        ))
    }

    /// Builds a `VScroll` and mounts it so it fills this view.
    ///
    /// The parameters match `VScroll.init`. Mounting goes to this view's edges and
    /// applies no safe-area inset.
    @discardableResult
    func addVScroll(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @UIViewBuilder content: () -> [UIView]
    ) -> VScroll {
        addContent(VScroll(
            alignment: alignment,
            spacing: spacing,
            showsIndicators: showsIndicators,
            content: content
        ))
    }
}
