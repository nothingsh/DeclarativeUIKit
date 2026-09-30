import UIKit

@MainActor
public extension UIView {

    /// Adds `content` as a subview and pins its four directional edges to this view.
    ///
    /// By default every edge is pinned to this view's own edge, so the content fills its
    /// bounds. The edges named in `safeArea` are pinned to this view's `safeAreaLayoutGuide`
    /// instead, so the content, and any background it draws, stays inside the safe area on
    /// those edges and follows it when it changes.
    ///
    /// A view is meant to be mounted once. If the content already has a superview, that is
    /// reported and the content is removed from it first, which drops every constraint tying
    /// it to the old hierarchy, and then mounted again. Constraints therefore never accumulate.
    /// The content's own size constraints are not part of that hierarchy and are kept.
    /// Because the content is removed and re-added, a repeated mount moves it to the front of
    /// the subview order.
    ///
    /// - Returns: The same instance that was passed in, keeping its concrete type so
    ///   type-specific modifiers stay available.
    @discardableResult
    func addContent<Content: UIView>(_ content: Content, safeArea: LayoutEdges = []) -> Content {
        precondition(
            content !== self,
            "addContent cannot mount a view into itself."
        )
        precondition(
            !isDescendant(of: content),
            "addContent cannot mount a view into one of its own descendants."
        )

        if content.superview != nil {
            NSLog(
                "DeclarativeUIKit: addContent received %@, which is already mounted. "
                    + "A view should be mounted once. It is being removed from its current "
                    + "parent, dropping its existing constraints, and mounted again.",
                String(describing: type(of: content))
            )
            content.removeFromSuperview()
        }

        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(
                equalTo: safeArea.contains(.leading) ? guide.leadingAnchor : leadingAnchor
            ),
            content.trailingAnchor.constraint(
                equalTo: safeArea.contains(.trailing) ? guide.trailingAnchor : trailingAnchor
            ),
            content.topAnchor.constraint(
                equalTo: safeArea.contains(.top) ? guide.topAnchor : topAnchor
            ),
            content.bottomAnchor.constraint(
                equalTo: safeArea.contains(.bottom) ? guide.bottomAnchor : bottomAnchor
            )
        ])

        return content
    }
}
