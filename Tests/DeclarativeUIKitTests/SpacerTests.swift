import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class SpacerTests: XCTestCase {

    private func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }

    func testSpacerTakesTheRemainingLengthOnTheStackAxisOnly() {
        let hHost = LayoutTestHost(size: CGSize(width: 200, height: 100))
        let hSpacer = Spacer(minLength: 16)
        hHost.rootView.addHStack {
            fixedSizeView(width: 20, height: 20)
            hSpacer
            fixedSizeView(width: 30, height: 20)
        }
        hHost.layout()
        XCTAssertEqual(hSpacer.frame.width, 150)
        XCTAssertEqual(hSpacer.frame.height, 0, "The minimum length must not apply to the cross axis.")

        let vHost = LayoutTestHost(size: CGSize(width: 100, height: 200))
        let vSpacer = Spacer(minLength: 16)
        vHost.rootView.addVStack {
            fixedSizeView(width: 20, height: 20)
            vSpacer
            fixedSizeView(width: 20, height: 30)
        }
        vHost.layout()
        XCTAssertEqual(vSpacer.frame.height, 150)
        XCTAssertEqual(vSpacer.frame.width, 0, "The minimum length must not apply to the cross axis.")
    }

    func testRemainingSpacersStillShareEquallyAfterOneIsRemoved() {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 100))
        let spacers = [Spacer(), Spacer(), Spacer()]
        host.rootView.addHStack {
            spacers[0]
            fixedSizeView(width: 20, height: 20)
            spacers[1]
            fixedSizeView(width: 30, height: 20)
            spacers[2]
        }
        host.layout()
        XCTAssertEqual(spacers.map(\.frame.width), [50, 50, 50])

        spacers[0].removeFromSuperview()
        host.layout()
        XCTAssertEqual(spacers.dropFirst().map(\.frame.width), [75, 75])
    }

    func testSpacersShareTheRemainingLengthEqually() {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 100))
        let spacers = [Spacer(), Spacer(), Spacer()]
        let first = label("First")
        let second = label("Second")
        host.rootView.addHStack {
            spacers[0]
            first
            spacers[1]
            second
            spacers[2]
        }
        host.layout()

        // The labels keep their intrinsic widths: the spacers give way before content.
        XCTAssertEqual(first.frame.width, first.intrinsicContentSize.width)
        XCTAssertEqual(second.frame.width, second.intrinsicContentSize.width)
        let share = (200 - first.frame.width - second.frame.width) / 3
        for spacer in spacers {
            XCTAssertEqual(spacer.frame.width, share, accuracy: 0.5)
        }
    }

    func testMinimumLengthHoldsWhenTextNeedsTheSpace() {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 100))
        let text = label(String(repeating: "Long text ", count: 10))
        let spacer = Spacer(minLength: 16)
        host.rootView.addHStack {
            text
            spacer
            fixedSizeView(width: 30, height: 20)
        }
        host.layout()

        XCTAssertEqual(spacer.frame.width, 16)
        XCTAssertEqual(text.frame.width, 154)
    }

    func testPriorityModifiersDecideWhichLabelGivesWay() {
        let wideHost = LayoutTestHost(size: CGSize(width: 300, height: 100))
        let stretched: UILabel = label("A").contentHuggingPriority(.defaultLow - 1, for: .horizontal)
        let hugging = label("B")
        // With equal priorities UIKit stretches the first label, so the modifier has to
        // move the extra width to the second.
        wideHost.rootView.addHStack {
            hugging
            stretched
        }
        wideHost.layout()
        XCTAssertEqual(hugging.frame.width, hugging.intrinsicContentSize.width)
        XCTAssertEqual(stretched.frame.width, 300 - hugging.frame.width)

        let narrowHost = LayoutTestHost(size: CGSize(width: 200, height: 100))
        let resisting = label(String(repeating: "Kept ", count: 4))
        let compressed: UILabel = label(String(repeating: "Cut ", count: 20))
            .compressionResistancePriority(.defaultLow, for: .horizontal)
        // With equal priorities UIKit compresses the last label, so the modifier has to
        // move the shortfall to the first.
        narrowHost.rootView.addHStack {
            compressed
            resisting
        }
        narrowHost.layout()
        XCTAssertEqual(resisting.frame.width, resisting.intrinsicContentSize.width)
        XCTAssertEqual(compressed.frame.width, 200 - resisting.frame.width)
    }
}
