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
}
