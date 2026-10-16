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
    var accessories: [UICellAccessory] = []
    var onSelect: (() -> Void)?

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
}
