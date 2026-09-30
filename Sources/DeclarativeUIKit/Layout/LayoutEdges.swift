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
