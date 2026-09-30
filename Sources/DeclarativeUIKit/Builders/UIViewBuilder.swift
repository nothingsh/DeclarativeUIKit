import UIKit

/// Collects the views written in a content closure, in declaration order.
///
/// Accepts a view, an optional view, an array of views, `if` / `else`, `switch`,
/// `for`, `if #available` and empty content. An expression that is not a `UIView`
/// fails to compile rather than being dropped.
@resultBuilder
public enum UIViewBuilder {

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: UIView) -> [UIView] {
        [expression]
    }

    public static func buildExpression(_ expression: UIView?) -> [UIView] {
        expression.map { [$0] } ?? []
    }

    public static func buildExpression(_ expression: [UIView]) -> [UIView] {
        expression
    }

    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }

    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }

    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [UIView]) -> [UIView] {
        component
    }
}
