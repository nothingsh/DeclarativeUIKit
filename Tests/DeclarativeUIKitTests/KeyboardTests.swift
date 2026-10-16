import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class KeyboardTests: XCTestCase {

    private let screen = UIScreen.main.bounds

    /// Posts the notification the keyboard sends before it moves to `frame`, in screen
    /// coordinates.
    private func keyboardWillMove(to frame: CGRect) {
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: frame)]
        )
    }

    private func docked(height: CGFloat) -> CGRect {
        CGRect(x: 0, y: screen.maxY - height, width: screen.width, height: height)
    }

    func testCoveredHeightIsAddedToTheInsetsYouSet() {
        let host = LayoutTestHost(size: screen.size)
        let scroll = VScroll { UIView().frame(height: 2000) }.avoidsKeyboard(true)
        scroll.contentInset.bottom = 10
        host.rootView.addContent(scroll)
        host.layout()

        keyboardWillMove(to: docked(height: 300))
        XCTAssertEqual(scroll.contentInset.bottom, 310)
        XCTAssertEqual(scroll.verticalScrollIndicatorInsets.bottom, 300)

        keyboardWillMove(to: CGRect(x: 0, y: screen.maxY, width: screen.width, height: 300))
        XCTAssertEqual(scroll.contentInset.bottom, 10)
        XCTAssertEqual(scroll.verticalScrollIndicatorInsets.bottom, 0)
    }

    func testOnlyTheCoveredPartCounts() {
        let host = LayoutTestHost(size: screen.size)
        let scroll = VScroll { UIView().frame(height: 2000) }.avoidsKeyboard(true)
        host.rootView.addContent(VStack(alignment: .fill) {
            scroll
            UIView().frame(height: 200)
        })
        host.layout()

        keyboardWillMove(to: docked(height: 300))
        XCTAssertEqual(scroll.contentInset.bottom, 100)

        let floating = CGRect(x: 20, y: screen.midY, width: 300, height: 250)
        keyboardWillMove(to: floating)
        XCTAssertEqual(scroll.contentInset.bottom, 0)
    }

    func testFirstResponderIsScrolledAboveTheKeyboard() {
        let host = LayoutTestHost(size: screen.size)
        let field = UITextField().frame(height: 44)
        let scroll = VScroll(alignment: .fill) {
            UIView().frame(height: 1000)
            field
            UIView().frame(height: 1000)
        }
        .avoidsKeyboard(true)
        host.rootView.addContent(scroll)
        host.layout()
        XCTAssertTrue(field.becomeFirstResponder())

        let keyboard = docked(height: 300)
        keyboardWillMove(to: keyboard)
        host.layout()

        let fieldFrame = field.convert(field.bounds, to: nil)
        XCTAssertGreaterThanOrEqual(fieldFrame.minY, 0)
        XCTAssertLessThanOrEqual(fieldFrame.maxY, keyboard.minY)
        field.resignFirstResponder()
    }

    func testTurningOffRemovesTheInsetAndStopsFollowing() {
        let host = LayoutTestHost(size: screen.size)
        let scroll = VScroll { UIView().frame(height: 2000) }.avoidsKeyboard(true)
        host.rootView.addContent(scroll)
        host.layout()
        keyboardWillMove(to: docked(height: 300))

        scroll.avoidsKeyboard(false)
        XCTAssertEqual(scroll.contentInset.bottom, 0)

        keyboardWillMove(to: docked(height: 250))
        XCTAssertEqual(scroll.contentInset.bottom, 0)
    }

    func testTheSafeAreaUIKitAlreadyInsetsIsNotCountedTwice() {
        let host = LayoutTestHost(size: screen.size)
        let scroll = VScroll { UIView().frame(height: 2000) }
            .contentInsetAdjustmentBehavior(.always)
            .avoidsKeyboard(true)
        host.rootView.addContent(scroll)
        host.layout()
        let safeArea = scroll.adjustedContentInset.bottom
        XCTAssertGreaterThan(safeArea, 0)

        keyboardWillMove(to: docked(height: 300))
        XCTAssertEqual(scroll.contentInset.bottom, 300 - safeArea)
        XCTAssertEqual(scroll.adjustedContentInset.bottom, 300)
    }
}
