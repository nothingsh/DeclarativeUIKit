import UIKit

@MainActor
public extension UIView {

    /// Builds an `HStack` and mounts it so it fills this view.
    ///
    /// The parameters match `HStack.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addHStack(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        safeArea: LayoutEdges = [],
        @UIViewBuilder content: () -> [UIView]
    ) -> HStack {
        addContent(HStack(alignment: alignment, spacing: spacing, content: content), safeArea: safeArea)
    }

    /// Builds a `VStack` and mounts it so it fills this view.
    ///
    /// The parameters match `VStack.init`. Mounting goes through `addContent`: the edges named
    /// in `safeArea` are pinned to this view's safe area, the others to its edges.
    @discardableResult
    func addVStack(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        safeArea: LayoutEdges = [],
        @UIViewBuilder content: () -> [UIView]
    ) -> VStack {
        addContent(VStack(alignment: alignment, spacing: spacing, content: content), safeArea: safeArea)
    }
}
