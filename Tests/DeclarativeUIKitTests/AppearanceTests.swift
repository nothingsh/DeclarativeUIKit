import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class AppearanceTests: XCTestCase {

    /// Black in light mode and white in dark mode.
    private let dynamic = UIColor { $0.userInterfaceStyle == .dark ? .white : .black }

    private func setStyle(_ style: UIUserInterfaceStyle, in host: LayoutTestHost) {
        host.rootView.window?.overrideUserInterfaceStyle = style
        host.layout()
    }

    func testBorderAndShadowColorsFollowTheAppearance() {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 200))
        let card = UIView()
            .border(color: dynamic, width: 1)
            .shadow(color: dynamic, opacity: 0.2, radius: 4)
        host.rootView.addContent(card)
        setStyle(.light, in: host)
        XCTAssertEqual(card.layer.borderColor, UIColor.black.cgColor)

        setStyle(.dark, in: host)
        XCTAssertEqual(card.layer.borderColor, UIColor.white.cgColor)
        XCTAssertEqual(card.layer.shadowColor, UIColor.white.cgColor)

        setStyle(.light, in: host)
        XCTAssertEqual(card.layer.shadowColor, UIColor.black.cgColor)
    }

    func testCornerRadiusRoundsOnlyTheGivenCorners() {
        let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let card = UIView().cornerRadius(12, corners: top)

        XCTAssertEqual(card.layer.cornerRadius, 12)
        XCTAssertEqual(card.layer.maskedCorners, top)
    }

    func testGradientColorsFollowTheAppearance() throws {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 200))
        let gradient = GradientView([dynamic, .red])
        host.rootView.addContent(gradient)
        setStyle(.dark, in: host)

        let colors = try XCTUnwrap((gradient.layer as? CAGradientLayer)?.colors as? [CGColor])
        XCTAssertEqual(colors.first, UIColor.white.cgColor)
    }

    func testDividerSpansItsStackInsideThePadding() {
        let host = LayoutTestHost(size: CGSize(width: 300, height: 400))
        let horizontal = Divider()
        let vertical = Divider()
        let column = VStack(alignment: .center) {
            UILabel().text("Title")
            horizontal
            HStack(alignment: .center) {
                UILabel().text("A")
                vertical
                UILabel().text("B")
            }
            .padding(.vertical, 6)
        }
        .padding(horizontal: 12, vertical: 0)
        host.rootView.addContent(column, safeArea: [])
        host.layout()
        let pixel = 1 / host.rootView.traitCollection.displayScale

        XCTAssertEqual(horizontal.frame.width, 276)
        XCTAssertEqual(horizontal.frame.height, pixel)
        XCTAssertEqual(vertical.frame.width, pixel)
        XCTAssertEqual(vertical.frame.height, vertical.superview!.bounds.height - 12)
    }

    func testCombinedAccessibilityLabelFollowsTheDescendants() throws {
        let name = UILabel().text("Ada")
        let photo = UIImageView().accessibilityLabel("Photo")
        let role = UILabel().text("Mathematician")
        let card = VStack {
            name
            HStack {
                photo
                role
            }
            UILabel().text("Hidden").isHidden(true)
        }
        .accessibilityCombined()
        let element = try XCTUnwrap(card.accessibilityElements?.first as? UIAccessibilityElement)

        XCTAssertFalse(card.isAccessibilityElement)
        XCTAssertEqual(element.accessibilityLabel, "Ada, Photo, Mathematician")
        role.text("Countess")
        XCTAssertEqual(element.accessibilityLabel, "Ada, Photo, Countess")
    }
}
