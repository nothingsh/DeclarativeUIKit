import UIKit

/// A horizontal stack of views, backed by `UIStackView`.
///
/// Constructing a stack does not mount it. Compose structural modifiers first and
/// mount the result with `addContent`, or use `addHStack` to build and mount in
/// one step.
public final class HStack: UIStackView {

    /// - Parameters:
    ///   - alignment: How the elements line up on the vertical axis.
    ///   - spacing: The distance between elements. There is none by default.
    ///   - content: The elements, in leading-to-trailing order.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 0,
        @UIViewBuilder content: () -> [UIView]
    ) {
        super.init(frame: .zero)
        axis = .horizontal
        self.alignment = alignment.stackAlignment
        self.spacing = spacing
        arrange(content())
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("HStack is built in code and does not support init(coder:).")
    }

    /// Sets how the elements line up on the vertical axis.
    @discardableResult
    public func alignment(_ value: VerticalAlignment) -> Self {
        self.alignment = value.stackAlignment
        return self
    }
}
