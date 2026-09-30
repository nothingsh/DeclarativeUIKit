import UIKit

/// A vertically scrolling stack of views, backed by `UIScrollView`.
///
/// The elements are arranged by an embedded `VStack` whose width follows the scroll view
/// and whose height sets how far it scrolls. Constructing a scroll view does not mount it;
/// use `addContent`, or `addVScroll` to build and mount in one step.
public final class VScroll: UIScrollView {

    /// The stack that arranges the elements, for configuration without a forwarding modifier.
    public let stack: VStack

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

    /// Sets whether the vertical scroll indicator is shown.
    @discardableResult
    public func showsIndicators(_ value: Bool) -> Self {
        showsVerticalScrollIndicator = value
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
}
