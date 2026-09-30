import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class LayoutTestHostTests: XCTestCase {
    func testRootViewUsesRequestedSizeInARealWindow() throws {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.layout()

        XCTAssertEqual(host.rootView.bounds.size, CGSize(width: 320, height: 640))
        let window = try XCTUnwrap(host.rootView.window)
        XCTAssertNotNil(window.rootViewController)
        XCTAssertFalse(window.isHidden)
    }

    func testResizeUpdatesRootAndConstrainedContent() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        host.rootView.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: host.rootView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: host.rootView.trailingAnchor),
            content.topAnchor.constraint(equalTo: host.rootView.topAnchor),
            content.bottomAnchor.constraint(equalTo: host.rootView.bottomAnchor)
        ])
        host.layout()
        XCTAssertEqual(content.frame.size, CGSize(width: 320, height: 640))

        host.resize(to: CGSize(width: 640, height: 320))
        host.layout()

        XCTAssertEqual(host.rootView.bounds.size, CGSize(width: 640, height: 320))
        XCTAssertEqual(content.frame, CGRect(x: 0, y: 0, width: 640, height: 320))
    }

    func testAdditionalSafeAreaInsetsMoveGuideAndReset() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.layout()
        let original = host.rootView.safeAreaLayoutGuide.layoutFrame

        host.setAdditionalSafeAreaInsets(UIEdgeInsets(top: 11, left: 13, bottom: 17, right: 19))
        host.layout()
        let inset = host.rootView.safeAreaLayoutGuide.layoutFrame
        XCTAssertEqual(inset.minX, original.minX + 13, accuracy: 0.01)
        XCTAssertEqual(inset.minY, original.minY + 11, accuracy: 0.01)
        XCTAssertEqual(inset.maxX, original.maxX - 19, accuracy: 0.01)
        XCTAssertEqual(inset.maxY, original.maxY - 17, accuracy: 0.01)

        host.setAdditionalSafeAreaInsets(.zero)
        host.layout()
        XCTAssertEqual(host.rootView.safeAreaLayoutGuide.layoutFrame, original)
    }

    func testInitialAdditionalSafeAreaInsetsAreApplied() {
        let host = LayoutTestHost(
            size: CGSize(width: 320, height: 640),
            additionalSafeAreaInsets: UIEdgeInsets(top: 11, left: 13, bottom: 17, right: 19)
        )
        host.layout()
        let initial = host.rootView.safeAreaLayoutGuide.layoutFrame
        host.setAdditionalSafeAreaInsets(.zero)
        host.layout()
        let original = host.rootView.safeAreaLayoutGuide.layoutFrame

        XCTAssertEqual(initial.minX, original.minX + 13, accuracy: 0.01)
        XCTAssertEqual(initial.minY, original.minY + 11, accuracy: 0.01)
        XCTAssertEqual(initial.maxX, original.maxX - 19, accuracy: 0.01)
        XCTAssertEqual(initial.maxY, original.maxY - 17, accuracy: 0.01)
    }

    func testReleasingHostReleasesWindowControllerAndView() {
        weak var window: UIWindow?
        weak var controller: UIViewController?
        weak var rootView: UIView?
        autoreleasepool {
            let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
            host.layout()
            window = host.rootView.window
            controller = window?.rootViewController
            rootView = host.rootView
            XCTAssertNotNil(window)
            XCTAssertNotNil(controller)
            XCTAssertNotNil(rootView)
        }

        XCTAssertNil(window)
        XCTAssertNil(controller)
        XCTAssertNil(rootView)
    }
}
