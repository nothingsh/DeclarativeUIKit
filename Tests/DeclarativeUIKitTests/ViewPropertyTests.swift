import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class ViewPropertyTests: XCTestCase {

    private final class BadgeView: UIView {
        var count = 0
    }

    func testViewModifiersSetPropertiesAndKeepTheLabel() {
        let label = UILabel()

        let result: UILabel = label
            .alpha(0.2)
            .alpha(0.5)
            .isHidden(true)
            .isUserInteractionEnabled(true)
            .contentMode(.scaleAspectFit)
            .tintColor(.green)
            .clipsToBounds(true)
            .accessibilityLabel("Title")
            .accessibilityIdentifier("title")
            .text("标题")

        XCTAssertTrue(result === label)
        XCTAssertEqual(result.alpha, 0.5, "The last modifier of the same property wins.")
        XCTAssertTrue(result.isHidden)
        XCTAssertTrue(result.isUserInteractionEnabled)
        XCTAssertEqual(result.contentMode, .scaleAspectFit)
        XCTAssertEqual(result.tintColor, .green)
        XCTAssertTrue(result.clipsToBounds)
        XCTAssertEqual(result.accessibilityLabel, "Title")
        XCTAssertEqual(result.accessibilityIdentifier, "title")
        XCTAssertEqual(result.text, "标题")
    }

    func testLabelModifiers() {
        let attributed = NSAttributedString(string: "Attributed")
        let font = UIFont.systemFont(ofSize: 21)

        let label = UILabel()
            .font(font)
            .textColor(.blue)
            .numberOfLines(3)
            .textAlignment(.center)
            .lineBreakMode(.byTruncatingMiddle)

        XCTAssertEqual(label.font, font)
        XCTAssertFalse(
            label.adjustsFontForContentSizeCategory,
            "A plain font keeps UIKit's native behaviour."
        )
        XCTAssertEqual(label.textColor, .blue)
        XCTAssertEqual(label.numberOfLines, 3)
        XCTAssertEqual(label.textAlignment, .center)
        XCTAssertEqual(label.lineBreakMode, .byTruncatingMiddle)

        label.attributedText(attributed)
        XCTAssertEqual(label.attributedText?.string, "Attributed")
    }

    func testImageViewModifiers() {
        let image = UIImage()
        let highlighted = UIImage()

        let imageView: UIImageView = UIImageView()
            .image(image)
            .highlightedImage(highlighted)

        XCTAssertTrue(imageView.image === image)
        XCTAssertTrue(imageView.highlightedImage === highlighted)
    }

    func testCustomSubclassKeepsItsTypeThroughConfigure() {
        let badge = BadgeView()

        let result: BadgeView = badge
            .alpha(0.5)
            .configure { $0.count = 3 }

        XCTAssertTrue(result === badge)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.alpha, 0.5)
    }
}
