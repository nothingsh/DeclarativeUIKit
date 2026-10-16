import UIKit

/// A group of rows in a ``VList``, with an optional header and footer in UIKit's default
/// style for the list's appearance.
public struct ListSection<Item> {
    let id: ListID
    let header: String?
    let footer: String?
    let items: [Item]

    /// - Parameters:
    ///   - id: Identifies the section across updates. It must be unique within the list.
    ///   - header: The text above the section. Without it, the section has no header.
    ///   - footer: The text below the section. Without it, the section has no footer.
    ///   - items: The items of the section, in top-to-bottom order.
    public init<ID: Hashable & Sendable>(
        id: ID,
        header: String? = nil,
        footer: String? = nil,
        items: [Item]
    ) {
        self.id = ListID(id)
        self.header = header
        self.footer = footer
        self.items = items
    }
}

/// An identifier for diffable data sources. It is built only from `Hashable & Sendable`
/// values, so the unchecked conformance holds.
struct ListID: Hashable, @unchecked Sendable {
    let base: AnyHashable

    init<ID: Hashable & Sendable>(_ id: ID) {
        base = id
    }
}

/// A vertically scrolling list that creates rows lazily and updates them by diffing,
/// backed by `UICollectionView`.
///
/// Rows are declared by the `row` closure, which the list calls whenever a row is shown
/// or its item changes. Pass new data with `update`; the list inserts, removes and moves
/// rows by `id`, and refreshes the rows whose id is in both the old and the new data.
/// Ids must be unique across the whole list.
///
/// The list owns its `delegate` to handle selection; replacing it stops `onSelect` and
/// `onReachEnd`, and rows without an action highlight again.
/// Like ``VScroll``, it ignores the safe area by itself; mount it with
/// `addContent(_:safeArea:)` to keep it inside. The list keeps the `row` closure, so
/// capture a view controller weakly in it.
public final class VList<Item>: UICollectionView {
    private let id: (Item) -> ListID
    private let row: (Item) -> ListRow
    private let sections: SectionState
    private let listDelegate = ListDelegate()
    private var items: [ListID: Item] = [:]
    private var titled: [ListID: [Bool]] = [:]
    private var diffable: UICollectionViewDiffableDataSource<ListID, ListID>!

    /// - Parameters:
    ///   - items: The items, in top-to-bottom order, shown without animation.
    ///   - id: The key path to an item's identity, which must be unique within the list.
    ///   - appearance: The UIKit list appearance, which sets the background, separators
    ///     and cell backgrounds.
    ///   - row: Declares the row for an item.
    public convenience init<ID: Hashable & Sendable>(
        _ items: [Item] = [],
        id: KeyPath<Item, ID>,
        appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
        row: @escaping (Item) -> ListRow
    ) {
        self.init(sections: [ListSection(id: 0, items: items)], id: id, appearance: appearance, row: row)
    }

    /// - Parameters:
    ///   - sections: The sections, in top-to-bottom order, shown without animation.
    ///   - id: The key path to an item's identity, which must be unique within the list.
    ///   - appearance: The UIKit list appearance, which sets the background, separators
    ///     and cell backgrounds.
    ///   - row: Declares the row for an item.
    public init<ID: Hashable & Sendable>(
        sections: [ListSection<Item>],
        id: KeyPath<Item, ID>,
        appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
        row: @escaping (Item) -> ListRow
    ) {
        self.id = { ListID($0[keyPath: id]) }
        self.row = row
        let state = SectionState()
        self.sections = state
        let layout = UICollectionViewCompositionalLayout { index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: appearance)
            state.configure(&configuration)
            configuration.leadingSwipeActionsConfigurationProvider = { [unowned state] indexPath in
                state.cell(at: indexPath)?.leadingSwipeActions
            }
            configuration.trailingSwipeActionsConfigurationProvider = { [unowned state] indexPath in
                state.cell(at: indexPath)?.trailingSwipeActions
            }
            configuration.headerMode = state.headers[index] == nil ? .none : .supplementary
            configuration.footerMode = state.footers[index] == nil ? .none : .supplementary
            return .list(using: configuration, layoutEnvironment: environment)
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        contentInsetAdjustmentBehavior = .never
        delegate = listDelegate
        state.list = self

        let cell = UICollectionView.CellRegistration<RowCell, ListID> { [unowned self] cell, _, id in
            cell.apply(self.row(self.items[id]!))
        }
        let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, indexPath in
            Self.setText(state.headers[indexPath.section], of: view)
        }
        let footer = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { view, _, indexPath in
            Self.setText(state.footers[indexPath.section], of: view)
        }
        diffable = UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, id in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: id)
        }
        diffable.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: kind == UICollectionView.elementKindSectionHeader ? header : footer,
                for: indexPath
            )
        }
        update(sections: sections, animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("VList is built in code and does not support init(coder:).")
    }

    /// Replaces the items of a list built without sections.
    public func update(_ items: [Item], animated: Bool = true) {
        update(sections: [ListSection(id: 0, items: items)], animated: animated)
    }

    /// Replaces the sections. Rows are inserted, removed and moved by id, and every row
    /// whose id is in both the old and the new data is configured again.
    public func update(sections: [ListSection<Item>], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ListID, ListID>()
        var next: [ListID: Item] = [:]
        for section in sections {
            let ids = section.items.map(id)
            snapshot.appendSections([section.id])
            snapshot.appendItems(ids, toSection: section.id)
            for (key, item) in zip(ids, section.items) {
                next[key] = item
            }
        }
        snapshot.reconfigureItems(snapshot.itemIdentifiers.filter { items[$0] != nil })
        items = next

        // A section that gains or loses a header or footer needs a new layout section.
        // iOS 15 creates one only when the section is reloaded; invalidating the layout
        // is not enough.
        let titled = Dictionary(uniqueKeysWithValues: sections.map { ($0.id, [$0.header != nil, $0.footer != nil]) })
        snapshot.reloadSections(snapshot.sectionIdentifiers.filter { id in
            self.titled[id].map { $0 != titled[id] } ?? false
        })
        self.titled = titled
        self.sections.headers = sections.map(\.header)
        self.sections.footers = sections.map(\.footer)
        diffable.apply(snapshot, animatingDifferences: animated)
        backgroundView?.isHidden = !items.isEmpty

        for (kind, titles) in [
            (UICollectionView.elementKindSectionHeader, self.sections.headers),
            (UICollectionView.elementKindSectionFooter, self.sections.footers)
        ] {
            for indexPath in indexPathsForVisibleSupplementaryElements(ofKind: kind) {
                if let view = supplementaryView(forElementKind: kind, at: indexPath) as? UICollectionViewListCell {
                    Self.setText(titles[indexPath.section], of: view)
                }
            }
        }
    }

    /// Runs `action` when the last row is about to be shown, to load more items. It runs
    /// again each time the last row comes into view, including a new last row after an
    /// update, so ignore calls while a load is in progress. Replaces an earlier action.
    @discardableResult
    public func onReachEnd(_ action: @escaping () -> Void) -> Self {
        listDelegate.onReachEnd = action
        return self
    }

    /// Scrolls to the row with `id`, which must be in the list. By default the list
    /// scrolls only as far as needed to show the row.
    public func scrollTo<ID: Hashable & Sendable>(
        _ id: ID,
        at position: UICollectionView.ScrollPosition = [],
        animated: Bool = true
    ) {
        guard let indexPath = diffable.indexPath(for: ListID(id)) else {
            preconditionFailure("VList has no row with id \(id).")
        }
        scrollToItem(at: indexPath, at: position, animated: animated)
    }

    /// Shows `view` in the middle of the list while the list has no rows, even if it has
    /// section headers or footers. `nil` removes it. The view is kept in `backgroundView`.
    ///
    /// `offset` moves the view from the middle: x is positive toward the right and y
    /// toward the bottom. The view stays within the layout margins, which win over a
    /// horizontal offset.
    @discardableResult
    public func emptyView(_ view: UIView?, offset: CGPoint = .zero) -> Self {
        backgroundView = view.map { view in
            let container = UIView()
            container.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            let centerX = view.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: offset.x)
                .named("emptyView.centerX")
            centerX.priority = .required - 1
            NSLayoutConstraint.activate([
                centerX,
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: offset.y)
                    .named("emptyView.centerY"),
                view.leadingAnchor.constraint(greaterThanOrEqualTo: container.layoutMarginsGuide.leadingAnchor)
                    .named("emptyView.leading"),
                view.trailingAnchor.constraint(lessThanOrEqualTo: container.layoutMarginsGuide.trailingAnchor)
                    .named("emptyView.trailing")
            ])
            container.isHidden = !items.isEmpty
            return container
        }
        return self
    }

    /// Adjusts the list configuration of every section, such as `separatorConfiguration`
    /// or `backgroundColor`. Replaces the body of an earlier call. The list sets
    /// `headerMode`, `footerMode` and the swipe action providers after `body` runs, so
    /// `body` cannot change them.
    @discardableResult
    public func listConfiguration(
        _ body: @escaping (inout UICollectionLayoutListConfiguration) -> Void
    ) -> Self {
        sections.configure = body
        collectionViewLayout.invalidateLayout()
        return self
    }

    private static func setText(_ text: String?, of view: UICollectionViewListCell) {
        var content = view.defaultContentConfiguration()
        content.text = text
        view.contentConfiguration = content
    }
}

/// What the layout and the supplementary views read for each section. A reference type,
/// because the layout is created before the list exists.
private final class SectionState {
    weak var list: UICollectionView?
    var headers: [String?] = []
    var footers: [String?] = []
    var configure: (inout UICollectionLayoutListConfiguration) -> Void = { _ in }

    /// The cell shown at `indexPath`, whose swipe actions the layout reads.
    @MainActor func cell(at indexPath: IndexPath) -> RowCell? {
        list?.cellForItem(at: indexPath) as? RowCell
    }
}

/// A cell that keeps a reusable row's content across items of the same row type.
final class RowCell: UICollectionViewListCell {
    private(set) var content: UIView?
    private var contentType: ObjectIdentifier?
    private(set) var onSelect: (() -> Void)?
    private(set) var leadingSwipeActions: UISwipeActionsConfiguration?
    private(set) var trailingSwipeActions: UISwipeActionsConfiguration?

    func apply(_ row: ListRow) {
        if let standardContent = row.standardContent {
            content = nil
            contentType = nil
            contentConfiguration = standardContent(self)
        } else if let content, let type = row.contentType, type == contentType {
            row.update(content)
        } else {
            content?.removeFromSuperview()
            // Standard content replaced the content view; nil brings back an empty one.
            if contentConfiguration != nil {
                contentConfiguration = nil
            }
            let made = row.make()
            contentView.addContent(made)
            row.update(made)
            content = made
            contentType = row.contentType
        }
        accessories = row.accessories
        onSelect = row.onSelect
        leadingSwipeActions = row.leadingSwipeActions
        trailingSwipeActions = row.trailingSwipeActions
    }
}

/// Highlights and selects only rows that have an `onSelect` action, and reports when the
/// last row is about to be shown.
private final class ListDelegate: NSObject, UICollectionViewDelegate {
    var onReachEnd: (() -> Void)?

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 else { return }
        // The last row may be in an earlier section when the last sections are empty.
        let laterSections = indexPath.section + 1..<collectionView.numberOfSections
        if laterSections.allSatisfy({ collectionView.numberOfItems(inSection: $0) == 0 }) {
            onReachEnd?()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        (collectionView.cellForItem(at: indexPath) as? RowCell)?.onSelect != nil
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? RowCell)?.onSelect?()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
