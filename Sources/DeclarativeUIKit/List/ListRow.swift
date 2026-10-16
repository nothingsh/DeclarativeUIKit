import UIKit

/// A view that a list creates with `init()`, once per cell, and reuses for other items.
///
/// Any `UIView` subclass conforms by declaring it: the inherited `init()` meets the
/// requirement. Build the structure in the initializer and expose a method that fills it
/// in from an item.
@MainActor
public protocol ListRowView: UIView {
    init()
}

/// The content and behavior of one row in a ``VList``.
@MainActor
public struct ListRow {
    let contentType: ObjectIdentifier?
    let make: () -> UIView
    let update: (UIView) -> Void
    /// UIKit's standard content, which the cell shows in place of a view.
    var standardContent: ((UICollectionViewListCell) -> UIListContentConfiguration)?
    var accessories: [UICellAccessory] = []
    var onSelect: (() -> Void)?
    var leadingSwipeActions: UISwipeActionsConfiguration?
    var trailingSwipeActions: UISwipeActionsConfiguration?

    /// A row whose view the list creates with `init()`, once per cell, and reuses for
    /// other items. Everything that depends on the item belongs in `update`, which runs
    /// each time the row is shown or its item changes, so it should only assign values.
    public init<Content: ListRowView>(_ type: Content.Type, update: @escaping (Content) -> Void) {
        contentType = ObjectIdentifier(type)
        make = { Content() }
        self.update = { update($0 as! Content) }
    }

    /// A row whose view is rebuilt each time the row is shown or its item changes.
    ///
    /// Suits static, simple rows. State held by controls in the view, such as focus or a
    /// running animation, is lost on each rebuild; use a ``ListRowView`` for those rows.
    public init<Content: UIView>(_ content: @escaping () -> Content) {
        contentType = nil
        make = content
        update = { _ in }
    }

    /// A row in UIKit's standard style: text, secondary text and an image, laid out by
    /// the cell's default content configuration for the list's appearance.
    public init(text: String?, secondaryText: String? = nil, image: UIImage? = nil) {
        self.init(standardContent: { cell in
            var content = cell.defaultContentConfiguration()
            content.text = text
            content.secondaryText = secondaryText
            content.image = image
            return content
        })
    }

    /// A row in UIKit's standard style, shown with `content` as it is, such as
    /// `.valueCell()` with text on both sides.
    public init(content: UIListContentConfiguration) {
        self.init(standardContent: { _ in content })
    }

    private init(standardContent: @escaping (UICollectionViewListCell) -> UIListContentConfiguration) {
        contentType = nil
        make = { UIView() }
        update = { _ in }
        self.standardContent = standardContent
    }

    /// Sets the cell accessories, such as `.disclosureIndicator()` or `.checkmark()`.
    public func accessories(_ value: [UICellAccessory]) -> ListRow {
        var copy = self
        copy.accessories = value
        return copy
    }

    /// Makes the row highlight and respond to taps. The list calls `action` and then
    /// deselects the row. Rows without an action do not highlight.
    public func onSelect(_ action: @escaping () -> Void) -> ListRow {
        var copy = self
        copy.onSelect = action
        return copy
    }

    /// Sets the actions revealed by swiping the row from the leading edge. Each action's
    /// handler must call its completion handler, as UIKit requires.
    public func leadingSwipeActions(_ actions: [UIContextualAction], allowsFullSwipe: Bool = true) -> ListRow {
        var copy = self
        copy.leadingSwipeActions = Self.swipeActions(actions, allowsFullSwipe: allowsFullSwipe)
        return copy
    }

    /// Sets the actions revealed by swiping the row from the trailing edge. Each action's
    /// handler must call its completion handler, as UIKit requires.
    public func trailingSwipeActions(_ actions: [UIContextualAction], allowsFullSwipe: Bool = true) -> ListRow {
        var copy = self
        copy.trailingSwipeActions = Self.swipeActions(actions, allowsFullSwipe: allowsFullSwipe)
        return copy
    }

    private static func swipeActions(
        _ actions: [UIContextualAction],
        allowsFullSwipe: Bool
    ) -> UISwipeActionsConfiguration {
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = allowsFullSwipe
        return configuration
    }
}
