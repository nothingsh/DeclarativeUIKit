import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class TextLayoutTests: XCTestCase {

    private let longText = "A declarative layout library for UIKit built on plain views and Auto Layout."

    /// Pins `label` to the top and horizontal edges, leaving its height to the text.
    private func pinTop(_ label: UILabel, in host: LayoutTestHost) {
        label.translatesAutoresizingMaskIntoConstraints = false
        host.rootView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: host.rootView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: host.rootView.trailingAnchor),
            label.topAnchor.constraint(equalTo: host.rootView.topAnchor)
        ])
        host.layout()
    }

    func testMultilineTextRelayoutsWithWidth() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let label = UILabel().text(longText).numberOfLines(0)
        pinTop(label, in: host)
        let wideHeight = label.frame.height

        host.resize(to: CGSize(width: 160, height: 640))

        XCTAssertEqual(label.frame.width, 160)
        XCTAssertGreaterThan(label.frame.height, wideHeight)

        let narrowHeight = label.frame.height
        label.text(longText + " " + longText)
        host.layout()

        XCTAssertGreaterThan(
            label.frame.height,
            narrowHeight,
            "Updating the text through the kept reference must relayout."
        )
    }

    func testTextStyleFollowsContentSizeCategory() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("Trait overrides need iOS 17.")
        }
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let label = UILabel().text("Body").font(textStyle: .body)
        pinTop(label, in: host)
        host.setPreferredContentSizeCategory(.large)
        let regularFont = label.font!
        let regularHeight = label.intrinsicContentSize.height

        XCTAssertEqual(
            regularFont,
            UIFont.preferredFont(forTextStyle: .body, compatibleWith: label.traitCollection)
        )

        host.setPreferredContentSizeCategory(.accessibilityExtraLarge)

        XCTAssertGreaterThan(label.font.pointSize, regularFont.pointSize)
        XCTAssertGreaterThan(label.intrinsicContentSize.height, regularHeight)
        XCTAssertGreaterThan(label.frame.height, regularHeight)
    }
}
