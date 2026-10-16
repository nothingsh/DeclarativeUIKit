import UIKit

/// A horizontally scrolling stack of views, backed by `UIScrollView`.
///
/// The elements are arranged by an embedded `HStack` whose height follows the scroll view
/// and whose width sets how far it scrolls. Constructing a scroll view does not mount it;
/// use `addContent`, or `addHScroll` to build and mount in one step.
public final class HScroll: UIScrollView {

    /// The stack that arranges the elements, for configuration without a forwarding modifier.
    public let stack: HStack

    private lazy var fillsViewportConstraint = stack.widthAnchor.constraint(
        greaterThanOrEqualTo: frameLayoutGuide.widthAnchor
    )

    /// - Parameters:
    ///   - alignment: How the elements line up on the vertical axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - showsIndicators: Whether the horizontal scroll indicator is shown.
    ///   - content: The elements, in leading-to-trailing order.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @UIViewBuilder content: () -> [UIView]
    ) {
        stack = HStack(alignment: alignment, spacing: spacing, content: content)
        super.init(frame: .zero)
        contentInsetAdjustmentBehavior = .never
        showsHorizontalScrollIndicator = showsIndicators
        mount(stack, scrolling: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("HScroll is built in code and does not support init(coder:).")
    }

    public override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        fillsViewportConstraint.constant = -(adjustedContentInset.left + adjustedContentInset.right)
    }

    /// Sets whether the horizontal scroll indicator is shown.
    @discardableResult
    public func showsIndicators(_ value: Bool) -> Self {
        showsHorizontalScrollIndicator = value
        return self
    }

    /// Sets whether the content is at least as wide as the scroll view. Off by default, so
    /// short content keeps its own width.
    ///
    /// The extra width goes to a `Spacer`, which can push the elements after it to the
    /// trailing edge. Wider content scrolls as usual. The width inside
    /// `adjustedContentInset` counts.
    @discardableResult
    public func fillsViewport(_ value: Bool) -> Self {
        fillsViewportConstraint.isActive = value
        return self
    }

    /// Sets how the elements line up on the vertical axis.
    @discardableResult
    public func alignment(_ value: VerticalAlignment) -> Self {
        stack.alignment(value)
        return self
    }

    /// Sets the distance between elements.
    @discardableResult
    public func spacing(_ value: CGFloat) -> Self {
        stack.spacing(value)
        return self
    }

    /// Sets the distance after `view`, in place of `spacing`. `view` must already be one
    /// of the elements.
    @discardableResult
    public func spacing(_ value: CGFloat, after view: UIView) -> Self {
        stack.spacing(value, after: view)
        return self
    }

    /// Replaces the elements with new content. The old elements are removed from the view
    /// hierarchy.
    @discardableResult
    public func replaceContent(@UIViewBuilder _ content: () -> [UIView]) -> Self {
        stack.replaceContent(content)
        return self
    }

    /// Sets the same padding on every edge, inside the scrolled content.
    @discardableResult
    public func padding(_ length: CGFloat) -> Self {
        stack.padding(length)
        return self
    }

    /// Sets the padding of the given edges, inside the scrolled content, and keeps the
    /// other edges as they are.
    @discardableResult
    public func padding(_ edges: LayoutEdges, _ length: CGFloat) -> Self {
        stack.padding(edges, length)
        return self
    }

    /// Sets one padding for the leading and trailing edges and another for the top and
    /// bottom edges, inside the scrolled content.
    @discardableResult
    public func padding(horizontal: CGFloat, vertical: CGFloat) -> Self {
        stack.padding(horizontal: horizontal, vertical: vertical)
        return self
    }

    /// Sets the padding of each edge, inside the scrolled content.
    @discardableResult
    public func padding(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) -> Self {
        stack.padding(top: top, leading: leading, bottom: bottom, trailing: trailing)
        return self
    }

    /// Sets `length` on the given edges and `others` on the remaining edges, inside the
    /// scrolled content.
    @discardableResult
    public func padding(_ edges: LayoutEdges, _ length: CGFloat, others: CGFloat) -> Self {
        stack.padding(edges, length, others: others)
        return self
    }

    /// Sets the padding of every edge, inside the scrolled content.
    @discardableResult
    public func padding(_ insets: NSDirectionalEdgeInsets) -> Self {
        stack.padding(insets)
        return self
    }
}
