import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class ScrollTests: XCTestCase {

    func testElementsAreArrangedAlongTheScrollingAxisAndFollowTheViewportAcross() {
        let hHost = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let items = [
            fixedSizeView(width: 300, height: 20),
            fixedSizeView(width: 300, height: 20),
            fixedSizeView(width: 300, height: 20)
        ]
        let hScroll = hHost.rootView.addHScroll(alignment: .top, spacing: 10) {
            items[0]
            items[1]
            items[2]
        }
        hHost.layout()
        XCTAssertEqual(hScroll.frame, hHost.rootView.bounds)
        XCTAssertEqual(items.map(\.frame.minX), [0, 310, 620])
        XCTAssertEqual(items.map(\.frame.minY), [0, 0, 0])
        XCTAssertEqual(hScroll.contentSize, CGSize(width: 920, height: 200))

        let vHost = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let tall = fixedSizeView(width: 10, height: 600)
        let vScroll = vHost.rootView.addVScroll(alignment: .leading) { tall }
        vHost.layout()
        XCTAssertEqual(vScroll.frame, vHost.rootView.bounds)
        XCTAssertEqual(tall.frame.minX, 0)
        XCTAssertEqual(vScroll.contentSize, CGSize(width: 300, height: 600))
    }

    func testRightToLeftHScrollStartsAtTheFirstElement() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let first = fixedSizeView(width: 200, height: 20)
        let scroll = host.rootView.addHScroll {
            first
            fixedSizeView(width: 200, height: 20)
        }
        scroll.stack.semanticContentAttribute = .forceRightToLeft
        host.layout()
        XCTAssertEqual(scroll.contentOffset.x, 100)
        XCTAssertEqual(first.frame.maxX, scroll.bounds.maxX)

        scroll.stack.addArrangedSubview(fixedSizeView(width: 200, height: 20))
        host.layout()
        XCTAssertEqual(scroll.contentOffset.x, 300, "Growing content keeps the first element in view.")
        XCTAssertEqual(first.frame.maxX, scroll.bounds.maxX)
    }

    func testRightToLeftHScrollKeepsAnOffsetSetBeforeLayout() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let scroll = host.rootView.addHScroll {
            fixedSizeView(width: 200, height: 20)
            fixedSizeView(width: 200, height: 20)
        }
        scroll.stack.semanticContentAttribute = .forceRightToLeft
        host.layout()

        scroll.stack.addArrangedSubview(fixedSizeView(width: 200, height: 20))
        scroll.contentOffset.x = 0
        host.layout()
        XCTAssertEqual(scroll.contentOffset.x, 0)
    }

    func testIndicatorsAndInsetAdjustment() {
        let vScroll = VScroll { UIView() }
        XCTAssertTrue(vScroll.showsVerticalScrollIndicator)
        XCTAssertFalse(vScroll.showsIndicators(false).showsVerticalScrollIndicator)
        XCTAssertEqual(vScroll.contentInsetAdjustmentBehavior, .never)
        XCTAssertFalse(VScroll(showsIndicators: false) { UIView() }.showsVerticalScrollIndicator)

        let hScroll = HScroll { UIView() }
        XCTAssertTrue(hScroll.showsHorizontalScrollIndicator)
        XCTAssertFalse(hScroll.showsIndicators(false).showsHorizontalScrollIndicator)
        XCTAssertEqual(hScroll.contentInsetAdjustmentBehavior, .never)
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        XCTAssertFalse(host.rootView.addHScroll(showsIndicators: false) { UIView() }.showsHorizontalScrollIndicator)
    }

    func testForwardedModifiersConfigureTheEmbeddedStack() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let first = fixedSizeView(width: 20, height: 20)
        let second = fixedSizeView(width: 20, height: 20)
        let scroll = host.rootView.addVScroll {
            first
            second
        }
        .alignment(.trailing)
        .spacing(10)
        .padding(16)
        host.layout()
        XCTAssertEqual(first.frame.origin, CGPoint(x: 264, y: 16))
        XCTAssertEqual(second.frame.minY, 46)
        XCTAssertEqual(scroll.contentSize, CGSize(width: 300, height: 82))
    }

    func testReplaceContentUpdatesTheScrollingLength() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let scroll = host.rootView.addVScroll { fixedSizeView(width: 10, height: 600) }
        host.layout()

        scroll.replaceContent { fixedSizeView(width: 10, height: 900) }
        host.layout()
        XCTAssertEqual(scroll.stack.arrangedSubviews.count, 1)
        XCTAssertEqual(scroll.contentSize.height, 900)
    }

    func testWrappingTextUpdatesTheScrollingLength() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let text = UILabel().text(String(repeating: "Text ", count: 20)).numberOfLines(0)
        let scroll = host.rootView.addVScroll(alignment: .fill) { text }
        host.layout()
        let wideHeight = scroll.contentSize.height
        XCTAssertEqual(wideHeight, text.frame.height)

        host.resize(to: CGSize(width: 200, height: 200))
        XCTAssertEqual(scroll.contentSize.width, 200)
        XCTAssertEqual(text.frame.width, 200)
        XCTAssertGreaterThan(scroll.contentSize.height, wideHeight)
        let narrowHeight = scroll.contentSize.height

        text.text(String(repeating: "Text ", count: 40))
        host.layout()
        XCTAssertGreaterThan(scroll.contentSize.height, narrowHeight)
        XCTAssertEqual(scroll.contentSize.height, text.frame.height)
    }

    func testShortContentKeepsItsOwnLength() {
        let emptyHost = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let empty = emptyHost.rootView.addVScroll {}
        emptyHost.layout()
        XCTAssertEqual(empty.contentSize, CGSize(width: 300, height: 0))

        // Along the scrolling axis there is no remaining length for a spacer to take.
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let spacer = Spacer(minLength: 16)
        let scroll = host.rootView.addVScroll {
            fixedSizeView(width: 20, height: 20)
            spacer
            fixedSizeView(width: 20, height: 30)
        }
        host.layout()
        XCTAssertEqual(spacer.frame.height, 16)
        XCTAssertEqual(scroll.contentSize, CGSize(width: 300, height: 66))
    }

    func testVScrollFillsViewportStretchesShortContentToTheScrollViewHeight() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let footer = fixedSizeView(width: 20, height: 30)
        let header = fixedSizeView(width: 20, height: 20)
        let scroll = host.rootView.addVScroll {
            header
            Spacer()
            footer
        }
        .fillsViewport(true)
        host.layout()
        XCTAssertEqual(footer.frame.maxY, 200)
        XCTAssertEqual(scroll.contentSize.height, 200)

        header.constraints.first { $0.firstAttribute == .height }?.constant = 600
        host.layout()
        XCTAssertEqual(scroll.contentSize.height, 630)

        scroll.fillsViewport(false)
        header.constraints.first { $0.firstAttribute == .height }?.constant = 20
        host.layout()
        XCTAssertEqual(scroll.contentSize.height, 50)
    }

    func testHScrollFillsViewportStretchesShortContentToTheScrollViewWidth() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 200))
        let trailing = fixedSizeView(width: 30, height: 20)
        let scroll = host.rootView.addHScroll {
            fixedSizeView(width: 20, height: 20)
            Spacer()
            trailing
        }
        .fillsViewport(true)
        host.layout()
        XCTAssertEqual(trailing.frame.maxX, 300)
        XCTAssertEqual(scroll.contentSize.width, 300)
    }

    func testNestedHScrollTakesItsHeightFromItsElements() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 400))
        let row = HScroll(spacing: 8) {
            fixedSizeView(width: 200, height: 40)
            fixedSizeView(width: 200, height: 40)
        }
        let scroll = host.rootView.addVScroll(alignment: .fill) {
            fixedSizeView(width: 50, height: 100)
            row
        }
        host.layout()
        XCTAssertEqual(row.frame, CGRect(x: 0, y: 100, width: 300, height: 40))
        XCTAssertEqual(row.contentSize, CGSize(width: 408, height: 40))
        XCTAssertEqual(scroll.contentSize, CGSize(width: 300, height: 140))
    }

    func testEveryPaddingFormAndCustomSpacingReachTheEmbeddedStack() {
        let first = UIView()
        let vScroll = VScroll { first }

        vScroll.padding(horizontal: 12, vertical: 4)
        XCTAssertEqual(
            vScroll.stack.directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        )
        vScroll.padding(top: 1, leading: 2, bottom: 3, trailing: 4)
        XCTAssertEqual(
            vScroll.stack.directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        )
        vScroll.padding(.top, 24, others: 8)
        XCTAssertEqual(
            vScroll.stack.directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 24, leading: 8, bottom: 8, trailing: 8)
        )
        vScroll.spacing(10, after: first)
        XCTAssertEqual(vScroll.stack.customSpacing(after: first), 10)

        let insets = NSDirectionalEdgeInsets(top: 5, leading: 6, bottom: 7, trailing: 8)
        XCTAssertEqual(HScroll { UIView() }.padding(insets).stack.directionalLayoutMargins, insets)
    }

    func testOnRefreshRunsTheLatestActionAndStopsSpinning() async throws {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 400))
        var runs: [String] = []
        let scroll = host.rootView.addVScroll { UIView() }
            .onRefresh { runs.append("first") }
            .onRefresh { runs.append("second") }
        host.layout()
        let control = try XCTUnwrap(scroll.refreshControl)

        control.beginRefreshing()
        control.sendActions(for: .valueChanged)
        for _ in 0..<10 where control.isRefreshing {
            await Task.yield()
        }

        XCTAssertEqual(runs, ["second"])
        XCTAssertFalse(control.isRefreshing)
    }

    func testFillsViewportCountsOnlyTheHeightInsideTheAdjustedInsets() {
        let host = LayoutTestHost(
            size: CGSize(width: 300, height: 600),
            additionalSafeAreaInsets: UIEdgeInsets(top: 100, left: 0, bottom: 40, right: 0)
        )
        let scroll = host.rootView.addVScroll { UIView().frame(height: 50) }
            .fillsViewport(true)
            .contentInsetAdjustmentBehavior(.always)
        host.layout()

        XCTAssertEqual(scroll.contentSize.height, 600 - scroll.adjustedContentInset.top - scroll.adjustedContentInset.bottom)
        XCTAssertGreaterThan(scroll.adjustedContentInset.top, 100)
    }
}
