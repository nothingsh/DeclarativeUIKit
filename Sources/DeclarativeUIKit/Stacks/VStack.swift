import UIKit

/// A vertical stack of views, backed by `UIStackView`.
///
/// Constructing a stack does not mount it. Compose structural modifiers first and
/// mount the result with `addContent`, or use `addVStack` to build and mount in
/// one step.
public final class VStack: UIStackView {

    /// - Parameters:
    ///   - alignment: How the elements line up on the horizontal axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - content: The elements, in top-to-bottom order.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 0,
        @UIViewBuilder content: () -> [UIView]
    ) {
        super.init(frame: .zero)
        axis = .vertical
        self.alignment = alignment.stackAlignment
        self.spacing = spacing
        arrange(content())
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("VStack is built in code and does not support init(coder:).")
    }

    /// Sets how the elements line up on the horizontal axis.
    @discardableResult
    public func alignment(_ value: HorizontalAlignment) -> Self {
        self.alignment = value.stackAlignment
        return self
    }
}
