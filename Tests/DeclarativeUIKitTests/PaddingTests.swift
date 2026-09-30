import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class PaddingTests: XCTestCase {

    private func stack() -> VStack {
        VStack(alignment: .fill, spacing: 0) {
            fixedSizeView(width: 20, height: 30)
        }
    }

    func testPaddingIsAddedToFittingSize() {
        let padded: VStack = stack().padding(10).alignment(.leading)
        XCTAssertEqual(fittingSize(padded), CGSize(width: 40, height: 50))

        XCTAssertEqual(
            fittingSize(stack().padding(4).padding(6)),
            CGSize(width: 32, height: 42),
            "Padding is a property: the last call wins."
        )
        XCTAssertEqual(
            fittingSize(stack().padding(.horizontal, 5)),
            CGSize(width: 30, height: 30),
            "Edges not named stay at the stack's default of 0."
        )
        XCTAssertEqual(
            fittingSize(stack().padding(.horizontal, 16).padding(.vertical, 12)),
            CGSize(width: 52, height: 54),
            "A later call keeps the edges it does not name."
        )
        XCTAssertEqual(fittingSize(stack().padding()), CGSize(width: 52, height: 62))
    }

    func testSingleCallPaddingSetsEveryEdge() {
        XCTAssertEqual(
            fittingSize(stack().padding(horizontal: 12, vertical: 4)),
            CGSize(width: 44, height: 38)
        )
        XCTAssertEqual(
            stack().padding(1).padding(horizontal: 12, vertical: 4).directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        )
        XCTAssertEqual(
            stack().padding(1).padding(top: 2, leading: 3, bottom: 4, trailing: 5)
                .directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 2, leading: 3, bottom: 4, trailing: 5)
        )
        XCTAssertEqual(
            stack().padding(1).padding(.top, 24, others: 8).directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 24, leading: 8, bottom: 8, trailing: 8)
        )
        XCTAssertEqual(
            stack().padding([.leading, .bottom], 20, others: 6).directionalLayoutMargins,
            NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 20, trailing: 6)
        )
    }

    func testDirectionalPaddingMirrorsInRightToLeft() {
        let insets = NSDirectionalEdgeInsets(top: 1, leading: 10, bottom: 2, trailing: 30)

        func contentFrame(_ direction: UISemanticContentAttribute) -> CGRect {
            let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
            let content = UIView()
            let padded = VStack(alignment: .fill, spacing: 0) { content }.padding(insets)
            padded.semanticContentAttribute = direction
            host.rootView.addContent(padded)
            host.layout()
            return content.frame
        }

        XCTAssertEqual(
            contentFrame(.forceLeftToRight),
            CGRect(x: 10, y: 1, width: 280, height: 637)
        )
        XCTAssertEqual(
            contentFrame(.forceRightToLeft),
            CGRect(x: 30, y: 1, width: 280, height: 637)
        )
    }

    func testPaddingIgnoresTheSafeArea() {
        let host = LayoutTestHost(
            size: CGSize(width: 320, height: 640),
            additionalSafeAreaInsets: UIEdgeInsets(top: 40, left: 4, bottom: 30, right: 8)
        )
        let content = UIView()
        host.rootView.addContent(VStack(alignment: .fill, spacing: 0) { content }.padding(10))
        host.layout()

        XCTAssertNotEqual(host.rootView.safeAreaInsets, .zero)
        XCTAssertEqual(content.frame, host.rootView.bounds.insetBy(dx: 10, dy: 10))
    }
}
