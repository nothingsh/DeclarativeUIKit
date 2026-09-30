import UIKit

/// A set of directional edges. `leading` and `trailing` follow the layout direction,
/// so they mirror in right-to-left languages.
public struct LayoutEdges: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = LayoutEdges(rawValue: 1 << 0)
    public static let leading = LayoutEdges(rawValue: 1 << 1)
    public static let bottom = LayoutEdges(rawValue: 1 << 2)
    public static let trailing = LayoutEdges(rawValue: 1 << 3)

    public static let horizontal: LayoutEdges = [.leading, .trailing]
    public static let vertical: LayoutEdges = [.top, .bottom]
    public static let all: LayoutEdges = [.horizontal, .vertical]
}

@MainActor
public extension UIStackView {

    /// Sets the same padding on every edge.
    @discardableResult
    func padding(_ length: CGFloat) -> Self {
        padding(.all, length)
    }

    /// Sets the padding of the given edges and keeps the other edges as they are.
    @discardableResult
    func padding(_ edges: LayoutEdges = .all, _ length: CGFloat = 16) -> Self {
        var insets = directionalLayoutMargins
        if edges.contains(.top) { insets.top = length }
        if edges.contains(.leading) { insets.leading = length }
        if edges.contains(.bottom) { insets.bottom = length }
        if edges.contains(.trailing) { insets.trailing = length }
        return padding(insets)
    }

    /// Sets one padding for the leading and trailing edges and another for the top and
    /// bottom edges.
    @discardableResult
    func padding(horizontal: CGFloat, vertical: CGFloat) -> Self {
        padding(NSDirectionalEdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        ))
    }

    /// Sets the padding of each edge.
    @discardableResult
    func padding(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) -> Self {
        padding(NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }

    /// Sets `length` on the given edges and `others` on the remaining edges.
    @discardableResult
    func padding(_ edges: LayoutEdges, _ length: CGFloat, others: CGFloat) -> Self {
        padding(others).padding(edges, length)
    }

    /// Sets the padding of every edge, using directional layout margins that ignore
    /// the safe area.
    @discardableResult
    func padding(_ insets: NSDirectionalEdgeInsets) -> Self {
        directionalLayoutMargins = insets
        insetsLayoutMarginsFromSafeArea = false
        isLayoutMarginsRelativeArrangement = true
        return self
    }
}
