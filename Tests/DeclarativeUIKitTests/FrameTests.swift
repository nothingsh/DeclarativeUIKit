import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class FrameTests: XCTestCase {

    func testFixedFrameKeepsTheConcreteType() {
        let image: UIImageView = UIImageView()
            .frame(width: 100, height: 60)
            .image(UIImage())

        XCTAssertFalse(image.translatesAutoresizingMaskIntoConstraints)
        XCTAssertNil(image.superview, "frame must not wrap the view.")
        XCTAssertEqual(fittingSize(image), CGSize(width: 100, height: 60))
    }

    func testSizeRange() {
        let short = UILabel().text("Hi").frame(minWidth: 80, minHeight: 40)
        XCTAssertEqual(fittingSize(short), CGSize(width: 80, height: 40))

        let long = UILabel().text(String(repeating: "Long text ", count: 10))
        XCTAssertGreaterThan(long.intrinsicContentSize.width, 200)
        XCTAssertEqual(fittingSize(long.frame(maxWidth: 200)).width, 200)
    }

    func testRepeatedCallsRedefineTheAxis() {
        let view = UIView().frame(width: 100, height: 60)
        let width = view.constraints.first { $0.firstAttribute == .width }

        view.frame(width: 120)
        XCTAssertEqual(fittingSize(view), CGSize(width: 120, height: 60))
        XCTAssertEqual(view.constraints.count, 2)
        XCTAssertTrue(
            view.constraints.contains { $0 === width },
            "A repeated fixed length updates the existing constraint."
        )

        view.frame(minWidth: 50, maxWidth: 80)
        XCTAssertEqual(fittingSize(view), CGSize(width: 50, height: 60))
        XCTAssertEqual(view.constraints.count, 3, "The range replaces the fixed width.")

        view.frame(width: 30)
        XCTAssertEqual(
            fittingSize(view),
            CGSize(width: 30, height: 60),
            "A fixed width below the old minimum must not conflict with it."
        )
        XCTAssertEqual(view.constraints.count, 2)

        view.frame(maxWidth: 200)
        view.frame(minWidth: 40)
        XCTAssertEqual(
            view.constraints.map(\.relation).sorted { $0.rawValue < $1.rawValue },
            [.equal, .greaterThanOrEqual],
            "Only the fixed height and the latest minimum width remain."
        )
    }

    func testAspectRatio() {
        let view = UIView().frame(width: 120).frame(aspectRatio: 2)
        XCTAssertEqual(fittingSize(view), CGSize(width: 120, height: 60))

        view.frame(aspectRatio: 3)
        XCTAssertEqual(fittingSize(view), CGSize(width: 120, height: 40))
        XCTAssertEqual(view.constraints.count, 2, "A repeated ratio replaces the earlier one.")

        view.frame(aspectRatio: nil)
        XCTAssertEqual(view.constraints.map(\.firstAttribute), [.width])
    }

    func testInfiniteMaximumAddsNoConstraint() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let view = host.rootView.addContent(
            UIView().frame(minWidth: 80, maxWidth: .infinity, maxHeight: .infinity)
        )
        host.layout()

        XCTAssertEqual(view.constraints.map(\.firstAttribute), [.width])
        XCTAssertEqual(view.frame, host.rootView.bounds)

        host.resize(to: CGSize(width: 500, height: 300))
        XCTAssertEqual(view.frame.size, CGSize(width: 500, height: 300))
    }
}
