import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class StackTests: XCTestCase {

    private func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }

    func testConstructionDefaults() {
        let stack = VStack {
            label("First")
            label("Second")
        }

        XCTAssertEqual(stack.axis, .vertical)
        XCTAssertEqual(stack.alignment, .center)
        XCTAssertEqual(stack.spacing, UIStackView.spacingUseSystem)
        XCTAssertEqual(stack.distribution, .fill)
        XCTAssertNil(stack.superview, "Constructing a stack must not mount it anywhere.")
        XCTAssertEqual(stack.arrangedSubviews.count, 2)

        XCTAssertEqual(HStack { label("First") }.axis, .horizontal)
        XCTAssertEqual(VStack(spacing: 0) {}.spacing, 0)
    }

    func testSystemSpacingIsWiderThanNoSpacing() {
        let systemSpaced = VStack {
            label("First")
            label("Second")
        }
        let unspaced = VStack(spacing: 0) {
            label("First")
            label("Second")
        }

        XCTAssertGreaterThan(
            systemSpaced.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height,
            unspaced.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height,
            "nil spacing must resolve to real system spacing, not 0."
        )
    }

    func testAlignmentsMapToUIKitValues() {
        XCTAssertEqual(HStack(alignment: .top) {}.alignment, .top)
        XCTAssertEqual(HStack(alignment: .bottom) {}.alignment, .bottom)
        XCTAssertEqual(HStack(alignment: .firstTextBaseline) {}.alignment, .firstBaseline)
        XCTAssertEqual(HStack(alignment: .lastTextBaseline) {}.alignment, .lastBaseline)
        XCTAssertEqual(HStack(alignment: .fill) {}.alignment, .fill)

        XCTAssertEqual(VStack(alignment: .leading) {}.alignment, .leading)
        XCTAssertEqual(VStack(alignment: .trailing) {}.alignment, .trailing)
        XCTAssertEqual(VStack(alignment: .fill) {}.alignment, .fill)
    }

    func testModifiersOverrideConstructionValues() {
        let stack: VStack = VStack(alignment: .leading, spacing: 4) {}
            .spacing(12)
            .distribution(.equalSpacing)
            .alignment(.trailing)

        XCTAssertEqual(stack.spacing, 12)
        XCTAssertEqual(stack.distribution, .equalSpacing)
        XCTAssertEqual(stack.alignment, .trailing)
        XCTAssertEqual(VStack(spacing: 0) {}.spacing(nil).spacing, UIStackView.spacingUseSystem)

        // Configuring a stack after mounting it is supported; wrapping one is not.
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let mounted: VStack = host.rootView.addVStack {}.spacing(8).alignment(.leading)
        XCTAssertEqual(mounted.spacing, 8)
        XCTAssertEqual(mounted.alignment, .leading)
        XCTAssertTrue(mounted.superview === host.rootView)
    }

    func testAddVStackFillsParentAndStacksElementsVertically() {
        let host = LayoutTestHost(
            size: CGSize(width: 320, height: 640),
            additionalSafeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
        )
        let first = label("First")
        let second = label("Second")

        let stack: VStack = host.rootView.addVStack(alignment: .leading, spacing: 0) {
            first
            second
        }
        host.layout()

        XCTAssertTrue(stack.superview === host.rootView)
        XCTAssertNotEqual(
            host.rootView.safeAreaLayoutGuide.layoutFrame,
            host.rootView.bounds,
            "The host must have a real safe area for the next assertion to mean anything."
        )
        XCTAssertEqual(stack.frame, host.rootView.bounds, "Add methods mount to the parent's edges.")
        XCTAssertEqual(first.frame.minY, 0)
        XCTAssertEqual(second.frame.minY, first.frame.maxY, "spacing 0 leaves no gap.")
        XCTAssertEqual(second.frame.maxY, 640)
        XCTAssertEqual(first.frame.minX, 0)
        XCTAssertEqual(second.frame.minX, 0)
        XCTAssertFalse(stack.hasAmbiguousLayout)
    }

    func testAddHStackStacksElementsHorizontallyAndCentersThemOnTheCrossAxis() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let first = label("First")
        let second = label("Second")

        let stack: HStack = host.rootView.addHStack(spacing: 0) {
            first
            second
        }
        host.layout()

        XCTAssertEqual(stack.frame, host.rootView.bounds)
        XCTAssertEqual(first.frame.minX, 0)
        XCTAssertEqual(second.frame.minX, first.frame.maxX)
        XCTAssertEqual(second.frame.maxX, 320)
        XCTAssertLessThan(first.frame.height, 640, "Default alignment must not stretch the cross axis.")
        XCTAssertEqual(first.frame.midY, 320, accuracy: 0.5, "Default alignment centers on the cross axis.")
    }

    func testLeadingAlignmentMirrorsInRightToLeft() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let first = label("First")

        let stack: VStack = host.rootView.addVStack(alignment: .leading, spacing: 0) {
            first
        }
        stack.semanticContentAttribute = .forceRightToLeft
        host.layout()

        XCTAssertEqual(stack.effectiveUserInterfaceLayoutDirection, .rightToLeft)
        XCTAssertLessThan(first.frame.width, 320, "The label must be narrower than the stack to detect mirroring.")
        XCTAssertEqual(first.frame.maxX, 320, "Leading is the right edge in a right-to-left layout.")
    }
}
