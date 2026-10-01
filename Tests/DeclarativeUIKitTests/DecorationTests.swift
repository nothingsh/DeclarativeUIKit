import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class DecorationTests: XCTestCase {

    /// Places `view` at the host's top-leading corner, leaving its size to Auto Layout.
    private func place(_ view: UIView, in host: LayoutTestHost) {
        host.rootView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: host.rootView.topAnchor),
            view.leadingAnchor.constraint(equalTo: host.rootView.leadingAnchor)
        ])
        host.layout()
    }

    private func largeImageView() -> UIImageView {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 300)).image { _ in }
        return UIImageView(image: image)
    }

    func testFillDecorationDoesNotEnlargeTheView() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let label = UILabel().text("Title")
        let background = largeImageView()
        let overlay = largeImageView()
        // The label's size comes from its intrinsic size at a low hugging priority, so
        // only the decoration's lowered priorities keep the 200×300 image from winning.
        let stack = VStack(alignment: .fill, spacing: 0) { label }
            .background { background }
            .overlay { overlay }
        place(stack, in: host)

        XCTAssertEqual(stack.bounds.width, label.intrinsicContentSize.width, accuracy: 1)
        XCTAssertEqual(stack.bounds.height, label.intrinsicContentSize.height, accuracy: 1)
        XCTAssertEqual(background.frame, stack.bounds)
        XCTAssertEqual(overlay.frame, stack.bounds)
    }

    func testBackgroundColorSetsTheViewItself() {
        let label: UILabel = UILabel().background(.red)
        XCTAssertEqual(label.backgroundColor, .red)
        XCTAssertTrue(label.subviews.isEmpty)
    }

    func testBackgroundCoversPaddingAndFollowsContent() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let content = fixedSizeView(width: 20, height: 30)
        let background = UIView()
        let stack: VStack = VStack(alignment: .fill, spacing: 0) { content }
            .padding(10)
            .background { background }
        place(stack, in: host)

        XCTAssertTrue(stack.subviews.first === background)
        XCTAssertEqual(background.frame, CGRect(x: 0, y: 0, width: 40, height: 50))

        content.constraints.first { $0.firstAttribute == .width }!.constant = 50
        host.layout()
        XCTAssertEqual(background.frame, CGRect(x: 0, y: 0, width: 70, height: 50))
    }

    func testAlignmentPlacesDecoration() {
        func badgeFrame(
            _ alignment: LayoutAlignment,
            _ direction: UISemanticContentAttribute = .forceLeftToRight
        ) -> CGRect {
            let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
            let badge = fixedSizeView(width: 10, height: 10)
            let view = fixedSizeView(width: 100, height: 60)
                .overlay(alignment: alignment) { badge }
            view.semanticContentAttribute = direction
            place(view, in: host)
            return badge.frame
        }

        XCTAssertEqual(badgeFrame(.center), CGRect(x: 45, y: 25, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottom), CGRect(x: 45, y: 50, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.trailing), CGRect(x: 90, y: 25, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottomLeading), CGRect(x: 0, y: 50, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.topTrailing), CGRect(x: 90, y: 0, width: 10, height: 10))
        XCTAssertEqual(
            badgeFrame(.topTrailing, .forceRightToLeft),
            CGRect(x: 0, y: 0, width: 10, height: 10)
        )
    }

    func testOffsetMovesADecorationFromItsAlignment() {
        func badgeFrame(_ alignment: LayoutAlignment, _ offset: CGPoint) -> CGRect {
            let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
            let badge = fixedSizeView(width: 10, height: 10)
            let view = fixedSizeView(width: 100, height: 60)
                .overlay(alignment: alignment, offset: offset) { badge }
            place(view, in: host)
            return badge.frame
        }

        // x is positive toward the right and y toward the bottom, from where the alignment puts it.
        XCTAssertEqual(badgeFrame(.topTrailing, CGPoint(x: 4, y: -3)), CGRect(x: 94, y: -3, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.center, CGPoint(x: 5, y: 6)), CGRect(x: 50, y: 31, width: 10, height: 10))
        XCTAssertEqual(badgeFrame(.bottomLeading, CGPoint(x: -2, y: 2)), CGRect(x: -2, y: 52, width: 10, height: 10))

        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let behind = fixedSizeView(width: 10, height: 10)
        let stack: VStack = VStack(alignment: .fill, spacing: 0) { fixedSizeView(width: 20, height: 30) }
            .padding(10)
            .background(alignment: .bottom, offset: CGPoint(x: 0, y: 4)) { behind }
        place(stack, in: host)
        XCTAssertEqual(stack.bounds.size, CGSize(width: 40, height: 50), "An offset never resizes the view.")
        XCTAssertEqual(behind.frame, CGRect(x: 15, y: 44, width: 10, height: 10))
        XCTAssertTrue(stack.subviews.first === behind)
    }

    func testRepeatedDecorationsKeepDeclarationOrder() {
        let content = UIView()
        let (back1, back2, front1, front2) = (UIView(), UIView(), UIView(), UIView())
        let stack = VStack { content }
            .background { back1 }
            .background { back2 }
            .overlay { front1 }
            .overlay { front2 }

        XCTAssertEqual(
            stack.subviews.map(ObjectIdentifier.init),
            [back2, back1, content, front1, front2].map(ObjectIdentifier.init),
            "A later background goes further back; a later overlay goes further front."
        )
    }

    func testReaddedDecorationDropsItsEarlierConstraints() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let badge = fixedSizeView(width: 10, height: 10)
        let view = fixedSizeView(width: 100, height: 60)
            .overlay(alignment: .topLeading) { badge }
            .overlay(alignment: .bottomTrailing) { badge }
        place(view, in: host)

        XCTAssertEqual(view.subviews.count, 1)
        XCTAssertEqual(view.constraints.filter { $0.firstItem === badge }.count, 2)
        XCTAssertEqual(badge.frame, CGRect(x: 90, y: 50, width: 10, height: 10))
    }

    func testHitTestingFollowsLayering() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let button = UIButton().frame(width: 40, height: 20)
        let badgeButton = UIButton().frame(width: 10, height: 10)
        let stack = VStack(alignment: .fill, spacing: 0) { button }
            .padding(10)
            .background { UIView() }
            .overlay(alignment: .topTrailing) { badgeButton }
        place(stack, in: host)

        XCTAssertTrue(
            stack.hitTest(CGPoint(x: 20, y: 20), with: nil) === button,
            "The background stays behind the content."
        )
        XCTAssertTrue(stack.hitTest(CGPoint(x: 55, y: 5), with: nil) === badgeButton)
    }
}
