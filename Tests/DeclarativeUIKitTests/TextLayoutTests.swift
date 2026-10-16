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

    func testLineHeightSetsEachLineAndSurvivesNewTextAndFont() {
        let label = UILabel()
            .text("One\nTwo\nThree")
            .numberOfLines(0)
            .textAlignment(.center)
            .lineHeight(30)
            .font(.systemFont(ofSize: 16))

        XCTAssertEqual(label.intrinsicContentSize.height, 90, accuracy: 1)
        XCTAssertEqual(label.textAlignment, .center)

        label.text("One\nTwo")

        XCTAssertEqual(label.intrinsicContentSize.height, 60, accuracy: 1)
    }

    func testKerningSurvivesNewText() {
        let plain = UILabel().text("Kerning")
        let label = UILabel().kerning(4).text("Text").text("Kerning")

        XCTAssertGreaterThan(label.intrinsicContentSize.width, plain.intrinsicContentSize.width + 20)
    }

    func testLineHeightScalesWithDynamicType() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("Trait overrides need iOS 17.")
        }
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.setPreferredContentSizeCategory(.large)
        let label = UILabel().font(textStyle: .body).lineHeight(30).numberOfLines(0).text("One\nTwo")
        pinTop(label, in: host)
        let regularFont = label.font!
        let regularHeight = label.frame.height

        host.setPreferredContentSizeCategory(.accessibilityExtraLarge)

        XCTAssertGreaterThan(label.font.pointSize, regularFont.pointSize)
        XCTAssertEqual(
            label.frame.height / regularHeight,
            label.font.lineHeight / regularFont.lineHeight,
            accuracy: 0.1,
            "Lines must grow with the font, not keep their height."
        )
    }

    func testFontRelativeToTextStyleFollowsContentSizeCategory() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("Trait overrides need iOS 17.")
        }
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.setPreferredContentSizeCategory(.large)
        let brand = UIFont(name: "Georgia", size: 16)!
        let label = UILabel().text("Brand").font(brand, relativeTo: .body)
        pinTop(label, in: host)

        XCTAssertEqual(label.font.fontName, brand.fontName)
        XCTAssertEqual(label.font.pointSize, 16)

        host.setPreferredContentSizeCategory(.accessibilityExtraLarge)

        XCTAssertEqual(label.font.fontName, brand.fontName)
        XCTAssertGreaterThan(label.font.pointSize, 30)
    }
}
