import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class MountingTests: XCTestCase {

    /// Active constraints that tie `content` to `parent` by an edge.
    private func edgeConstraints(_ content: UIView, _ parent: UIView) -> [NSLayoutConstraint] {
        let edges: Set<NSLayoutConstraint.Attribute> = [
            .leading, .trailing, .top, .bottom, .left, .right
        ]
        return parent.constraints.filter { constraint in
            constraint.isActive
                && edges.contains(constraint.firstAttribute)
                && ((constraint.firstItem as? UIView) === content
                    || (constraint.secondItem as? UIView) === content)
        }
    }

    func testMountFillsParentIgnoringSafeArea() {
        let host = LayoutTestHost(
            size: CGSize(width: 320, height: 640),
            additionalSafeAreaInsets: UIEdgeInsets(top: 11, left: 13, bottom: 17, right: 19)
        )
        let content = UILabel()

        let returned: UILabel = host.rootView.addContent(content)
        host.layout()

        XCTAssertTrue(returned === content)
        XCTAssertNotEqual(
            host.rootView.safeAreaLayoutGuide.layoutFrame,
            host.rootView.bounds,
            "The host must have a real safe area for this assertion to mean anything."
        )
        XCTAssertEqual(content.frame, host.rootView.bounds)
        XCTAssertFalse(content.hasAmbiguousLayout)

        host.resize(to: CGSize(width: 640, height: 320))
        XCTAssertEqual(content.frame, host.rootView.bounds)
    }

    func testMountUsesDirectionalEdges() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.rootView.semanticContentAttribute = .forceRightToLeft
        let content = UIView()

        host.rootView.addContent(content)
        host.layout()

        XCTAssertEqual(host.rootView.effectiveUserInterfaceLayoutDirection, .rightToLeft)
        XCTAssertEqual(
            Set(edgeConstraints(content, host.rootView).map(\.firstAttribute)),
            [.leading, .trailing, .top, .bottom],
            "Horizontal edges must be leading/trailing so they mirror in RTL."
        )
        XCTAssertEqual(content.frame, host.rootView.bounds)
    }

    func testRepeatedMountDoesNotAccumulateConstraints() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let content = UIView()
        host.rootView.addContent(content)
        host.layout()
        XCTAssertEqual(edgeConstraints(content, host.rootView).count, 4)

        host.rootView.addContent(content)
        host.layout()

        XCTAssertEqual(edgeConstraints(content, host.rootView).count, 4)
        XCTAssertEqual(content.frame, host.rootView.bounds)
        XCTAssertFalse(content.hasAmbiguousLayout)
    }

    func testMountKeepsContentSizeConstraints() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        let width = content.widthAnchor.constraint(equalToConstant: 44)
        width.priority = .defaultHigh
        NSLayoutConstraint.activate([width])

        host.rootView.addContent(content)
        host.rootView.addContent(content)
        host.layout()

        XCTAssertTrue(
            width.isActive,
            "Mounting must not drop a size constraint the content owns."
        )
    }

    func testMountingIntoAnotherParentMovesContent() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let first = UIView()
        let second = UIView()
        host.rootView.addContent(first)
        host.rootView.addSubview(second)
        let content = UIView()
        first.addContent(content)
        host.layout()

        second.addContent(content)
        host.layout()

        XCTAssertTrue(content.superview === second)
        XCTAssertTrue(
            edgeConstraints(content, first).isEmpty,
            "Constraints spanning the old hierarchy must be gone."
        )
        XCTAssertEqual(edgeConstraints(content, second).count, 4)
    }
}
