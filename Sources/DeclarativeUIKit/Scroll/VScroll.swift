import UIKit

/// A vertically scrolling stack of views, backed by `UIScrollView`.
///
/// The elements are arranged by an embedded `VStack` whose width follows the scroll view
/// and whose height sets how far it scrolls. Constructing a scroll view does not mount it;
/// use `addContent`, or `addVScroll` to build and mount in one step.
public final class VScroll: UIScrollView {

    /// The stack that arranges the elements, for configuration without a forwarding modifier.
    public let stack: VStack

    private lazy var fillsViewportConstraint = stack.heightAnchor.constraint(
        greaterThanOrEqualTo: frameLayoutGuide.heightAnchor
    )

    /// - Parameters:
    ///   - alignment: How the elements line up on the horizontal axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - showsIndicators: Whether the vertical scroll indicator is shown.
    ///   - content: The elements, in top-to-bottom order.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        showsIndicators: Bool = true,
        @UIViewBuilder content: () -> [UIView]
    ) {
        stack = VStack(alignment: alignment, spacing: spacing, content: content)
        super.init(frame: .zero)
        contentInsetAdjustmentBehavior = .never
        showsVerticalScrollIndicator = showsIndicators
        mount(stack, scrolling: .vertical)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("VScroll is built in code and does not support init(coder:).")
    }

    public override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        fillsViewportConstraint.constant = -(adjustedContentInset.top + adjustedContentInset.bottom)
    }

    /// Sets whether the vertical scroll indicator is shown.
    @discardableResult
    public func showsIndicators(_ value: Bool) -> Self {
        showsVerticalScrollIndicator = value
        return self
    }

    /// Sets whether the content is at least as tall as the scroll view. Off by default, so
    /// short content keeps its own height.
    ///
    /// The extra height goes to a `Spacer`, which can push the elements after it to the
    /// bottom. Taller content scrolls as usual. The height inside `adjustedContentInset`
    /// counts, so the content fits between bars under an automatic adjustment behavior,
    /// and above the keyboard with `avoidsKeyboard(true)`.
    @discardableResult
    public func fillsViewport(_ value: Bool) -> Self {
        fillsViewportConstraint.isActive = value
        return self
    }

    /// Sets how the elements line up on the horizontal axis.
    @discardableResult
    public func alignment(_ value: HorizontalAlignment) -> Self {
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
    public func padding(_ edges: LayoutEdges = .all, _ length: CGFloat = 16) -> Self {
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
