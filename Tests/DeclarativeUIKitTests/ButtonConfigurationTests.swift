import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class ButtonConfigurationTests: XCTestCase {

    /// UIKit copies a title set with `setTitle(_:for:)` into the configuration
    /// when the button updates, so the button is laid out first.
    func testModifiersKeepEachOthersChanges() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let button = UIButton(configuration: .filled())
            .title("Save")
            .cornerStyle(.capsule)
            .imagePadding(8)
            .baseBackgroundColor(.systemRed)
            .title("Done")
        host.rootView.addSubview(button)
        host.layout()
        button.layoutIfNeeded()

        XCTAssertEqual(button.titleLabel?.text, "Done")
        let configuration = button.configuration!
        XCTAssertEqual(configuration.title, "Done")
        XCTAssertEqual(configuration.cornerStyle, .capsule)
        XCTAssertEqual(configuration.imagePadding, 8)
        XCTAssertEqual(configuration.baseBackgroundColor, .systemRed)
    }

    /// Checks the intrinsic size: on iOS 26 the frame follows a configuration
    /// change only in a later layout pass.
    func testContentInsetsChangeTheSize() {
        let button = UIButton(configuration: .filled()).title("Save")
        let size = button.intrinsicContentSize
        let defaultInsets = button.configuration!.contentInsets

        button.contentInsets(NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))

        XCTAssertEqual(
            button.intrinsicContentSize.width,
            size.width - defaultInsets.leading - defaultInsets.trailing + 60,
            accuracy: 1
        )
        XCTAssertEqual(
            button.intrinsicContentSize.height,
            size.height - defaultInsets.top - defaultInsets.bottom + 40,
            accuracy: 1
        )
    }

    func testTitleFontRelativeToTextStyleFollowsContentSizeCategory() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("Trait overrides need iOS 17.")
        }
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        host.setPreferredContentSizeCategory(.large)
        let brand = UIFont(name: "Georgia", size: 16)!
        let button = UIButton(configuration: .filled())
            .title("Save")
            .titleFont(brand, relativeTo: .body)
        host.rootView.addSubview(button)
        host.layout()
        button.layoutIfNeeded()

        XCTAssertEqual(button.titleLabel?.font.fontName, brand.fontName)
        XCTAssertEqual(button.titleLabel?.font.pointSize, 16)

        host.setPreferredContentSizeCategory(.accessibilityExtraLarge)
        button.layoutIfNeeded()

        XCTAssertEqual(button.titleLabel?.font.fontName, brand.fontName)
        XCTAssertGreaterThan(button.titleLabel?.font.pointSize ?? 0, 30)
    }

    func testTitleFontDoesNotKeepTheButtonAlive() {
        weak var weakButton: UIButton?
        autoreleasepool {
            let button = UIButton(configuration: .filled())
                .title("Save")
                .titleFont(textStyle: .headline)
            weakButton = button
        }

        XCTAssertNil(weakButton)
    }
}
