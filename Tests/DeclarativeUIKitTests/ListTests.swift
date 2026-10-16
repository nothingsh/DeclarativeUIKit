import UIKit
import XCTest
@testable import DeclarativeUIKit

private struct Entry {
    var id: Int
    var text: String
    var kind = 0
}

private final class TextRow: UIView, ListRowView {
    static var made = 0
    let label = UILabel().numberOfLines(0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        Self.made += 1
        addVStack { label }.padding(horizontal: 16, vertical: 12)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

private final class OtherRow: UIView, ListRowView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addContent(label)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

@MainActor
final class ListTests: XCTestCase {
    private var host: LayoutTestHost?

    override func tearDown() async throws {
        host = nil
    }

    private func mount(_ list: UICollectionView) {
        let host = LayoutTestHost(size: CGSize(width: 390, height: 844))
        host.rootView.addContent(list)
        host.layout()
        self.host = host
    }

    private func cells(_ list: UICollectionView) -> [RowCell] {
        list.layoutIfNeeded()
        return list.indexPathsForVisibleItems.sorted().map { list.cellForItem(at: $0) as! RowCell }
    }

    private func texts(_ list: UICollectionView) -> [String?] {
        cells(list).map { ($0.content as! TextRow).label.text }
    }

    private func textList(_ entries: [Entry]) -> VList<Entry> {
        VList(entries, id: \.id) { entry in
            ListRow(TextRow.self) { $0.label.text = entry.text }
        }
    }

    func testReusableRowsKeepTheirContentAcrossUpdates() {
        TextRow.made = 0
        let list = textList([Entry(id: 1, text: "a"), Entry(id: 2, text: "b")])
        mount(list)
        let before = cells(list).map(\.content)
        XCTAssertEqual(TextRow.made, 2)

        list.update([Entry(id: 1, text: "A"), Entry(id: 2, text: "B")])
        XCTAssertEqual(texts(list), ["A", "B"])
        XCTAssertTrue(zip(cells(list).map(\.content), before).allSatisfy { $0 === $1 })
        XCTAssertEqual(TextRow.made, 2)
    }

    func testInlineRowsAreRebuiltOnUpdate() {
        let list = VList([Entry(id: 1, text: "a")], id: \.id) { entry in
            ListRow { UILabel().text(entry.text) }
        }
        mount(list)
        let first = cells(list)[0].content

        list.update([Entry(id: 1, text: "b")])
        let content = cells(list)[0].content
        XCTAssertFalse(content === first)
        XCTAssertEqual((content as? UILabel)?.text, "b")
    }

    func testChangingTheRowTypeOfAnIDReplacesTheContent() {
        let list = VList([Entry(id: 1, text: "a")], id: \.id) { entry in
            entry.kind == 0
                ? ListRow(TextRow.self) { $0.label.text = entry.text }
                : ListRow(OtherRow.self) { $0.label.text = entry.text }
        }
        mount(list)
        XCTAssertTrue(cells(list)[0].content is TextRow)

        list.update([Entry(id: 1, text: "a", kind: 1)])
        XCTAssertEqual((cells(list)[0].content as? OtherRow)?.label.text, "a")
    }

    func testRowsFollowInsertionsRemovalsAndMoves() {
        let list = textList([Entry(id: 1, text: "1"), Entry(id: 2, text: "2"), Entry(id: 3, text: "3")])
        mount(list)

        list.update(
            [Entry(id: 3, text: "3"), Entry(id: 4, text: "4"), Entry(id: 1, text: "1")],
            animated: false
        )
        XCTAssertEqual(texts(list), ["3", "4", "1"])
    }

    func testRowsSizeToTheirContent() {
        let long = String(repeating: "Lorem ipsum dolor sit amet. ", count: 12)
        let list = textList([Entry(id: 1, text: "short"), Entry(id: 2, text: long)])
        mount(list)
        let rows = cells(list)

        let fitting = rows[1].contentView.systemLayoutSizeFitting(
            CGSize(width: 390, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        XCTAssertEqual(rows[1].frame.height, fitting.height, accuracy: 1)
        XCTAssertGreaterThan(rows[1].frame.height, rows[0].frame.height * 3)
    }

    func testSectionTitlesFollowUpdates() {
        let list = VList(
            sections: [
                ListSection(id: "a", header: "Account", items: [Entry(id: 1, text: "x")]),
                ListSection(id: "b", items: [Entry(id: 2, text: "y")])
            ],
            id: \.id,
            appearance: .insetGrouped
        ) { entry in
            ListRow(TextRow.self) { $0.label.text = entry.text }
        }
        mount(list)
        XCTAssertEqual(headerTexts(list), ["Account"])

        list.update([
            ListSection(id: "a", header: "Profile", items: [Entry(id: 1, text: "x")]),
            ListSection(id: "b", header: "About", items: [Entry(id: 2, text: "y")])
        ])
        XCTAssertEqual(headerTexts(list), ["Profile", "About"])
    }

    private func headerTexts(_ list: UICollectionView) -> [String?] {
        list.layoutIfNeeded()
        let kind = UICollectionView.elementKindSectionHeader
        return list.indexPathsForVisibleSupplementaryElements(ofKind: kind).sorted().map {
            let view = list.supplementaryView(forElementKind: kind, at: $0) as? UICollectionViewListCell
            return (view?.contentConfiguration as? UIListContentConfiguration)?.text
        }
    }

    func testOnlyRowsWithAnActionHighlightAndSelectionIsCleared() throws {
        var selected: [Int] = []
        let list = VList([Entry(id: 1, text: "a"), Entry(id: 2, text: "b")], id: \.id) { entry in
            let row = ListRow(TextRow.self) { $0.label.text = entry.text }
            return entry.id == 1 ? row.onSelect { selected.append(entry.id) } : row
        }
        mount(list)
        let delegate = try XCTUnwrap(list.delegate)
        let paths = list.indexPathsForVisibleItems.sorted()

        XCTAssertEqual(paths.map { delegate.collectionView!(list, shouldHighlightItemAt: $0) }, [true, false])
        list.selectItem(at: paths[0], animated: false, scrollPosition: [])
        delegate.collectionView!(list, didSelectItemAt: paths[0])
        XCTAssertEqual(selected, [1])
        XCTAssertEqual(list.indexPathsForSelectedItems, [])
    }

    func testStandardRowsSwitchWithReusableRowsInTheSameCell() {
        let list = VList([Entry(id: 1, text: "a")], id: \.id) { entry in
            entry.kind == 0
                ? ListRow(text: entry.text, secondaryText: "detail")
                : ListRow(TextRow.self) { $0.label.text = entry.text }
        }
        mount(list)
        let standard = cells(list)[0].contentConfiguration as? UIListContentConfiguration
        XCTAssertEqual(standard?.text, "a")
        XCTAssertEqual(standard?.secondaryText, "detail")

        for (kind, text) in [(1, "b"), (0, "c"), (1, "d")] {
            list.update([Entry(id: 1, text: text, kind: kind)], animated: false)
            let cell = cells(list)[0]
            if kind == 0 {
                XCTAssertEqual((cell.contentConfiguration as? UIListContentConfiguration)?.text, text)
            } else {
                XCTAssertNil(cell.contentConfiguration)
                XCTAssertEqual((cell.content as? TextRow)?.label.text, text)
                XCTAssertTrue(cell.content?.isDescendant(of: cell.contentView) == true)
            }
        }
    }

    func testSwipeActionsBelongToTheirRow() {
        let list = VList([Entry(id: 1, text: "a"), Entry(id: 2, text: "b")], id: \.id) { entry in
            let row = ListRow(text: entry.text)
            guard entry.id == 1 else { return row }
            return row.trailingSwipeActions(
                [UIContextualAction(style: .destructive, title: "Delete") { _, _, done in done(true) }],
                allowsFullSwipe: false
            )
        }
        mount(list)
        let rows = cells(list)

        XCTAssertEqual(rows[0].trailingSwipeActions?.actions.map(\.title), ["Delete"])
        XCTAssertEqual(rows[0].trailingSwipeActions?.performsFirstActionWithFullSwipe, false)
        XCTAssertNil(rows[0].leadingSwipeActions)
        XCTAssertNil(rows[1].trailingSwipeActions)
    }

    func testScrollToAndReachingTheEnd() {
        var reachedEnd = 0
        let list = textList((1...100).map { Entry(id: $0, text: "\($0)") }).onReachEnd { reachedEnd += 1 }
        mount(list)
        XCTAssertEqual(reachedEnd, 0)

        list.scrollTo(50, at: .top, animated: false)
        list.layoutIfNeeded()
        let row = list.cellForItem(at: IndexPath(item: 49, section: 0))
        XCTAssertEqual(row?.frame.minY ?? -1, list.contentOffset.y, accuracy: 0.5)
        XCTAssertEqual(reachedEnd, 0)

        list.scrollTo(100, animated: false)
        list.layoutIfNeeded()
        XCTAssertEqual(reachedEnd, 1)
    }

    func testEmptyViewShowsOnlyWithoutRows() throws {
        let message = UILabel().text("No entries")
        let list = textList([]).emptyView(message, offset: CGPoint(x: 10, y: -40))
        mount(list)
        let background = try XCTUnwrap(list.backgroundView)
        XCTAssertFalse(background.isHidden)
        let center = message.convert(CGPoint(x: message.bounds.midX, y: message.bounds.midY), to: list)
        XCTAssertEqual(center.x, list.bounds.midX + 10, accuracy: 0.5)
        XCTAssertEqual(center.y, list.bounds.midY - 40, accuracy: 0.5)

        list.update([Entry(id: 1, text: "a")])
        XCTAssertTrue(background.isHidden)
        list.update([Entry]())
        XCTAssertFalse(background.isHidden)
    }
}
