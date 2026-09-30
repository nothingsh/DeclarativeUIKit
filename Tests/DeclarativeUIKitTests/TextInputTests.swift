import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class TextInputTests: XCTestCase {

    private final class RecordingDelegate: NSObject, UITextFieldDelegate, UITextViewDelegate {
        var beginCount = 0
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            beginCount += 1
            return true
        }
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            beginCount += 1
            return true
        }
    }

    private let longText = String(
        repeating: "A declarative layout library for UIKit built on plain views and Auto Layout. ",
        count: 8
    )

    /// Pins `view` to the top and horizontal edges of the host.
    private func pinTop(_ view: UIView, in host: LayoutTestHost) {
        view.translatesAutoresizingMaskIntoConstraints = false
        host.rootView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: host.rootView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: host.rootView.trailingAnchor),
            view.topAnchor.constraint(equalTo: host.rootView.topAnchor)
        ])
        host.layout()
    }

    func testInputModifiersConfigureTraitsAndKeepNativeEditing() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let delegate = RecordingDelegate()
        let field = UITextField()
        let textView = UITextView()
        field.delegate = delegate
        textView.delegate = delegate

        let chainedField: UITextField = field
            .text("ada@example.com")
            .placeholder("Email")
            .keyboardType(.emailAddress)
            .returnKeyType(.next)
            .isSecureTextEntry(true)
        let chainedTextView: UITextView = textView
            .text("Notes")
            .keyboardType(.asciiCapable)
            .returnKeyType(.done)
            .isEditable(false)
            .isSelectable(false)

        XCTAssertTrue(chainedField === field)
        XCTAssertEqual(field.text, "ada@example.com")
        XCTAssertEqual(field.placeholder, "Email")
        XCTAssertEqual(field.keyboardType, .emailAddress)
        XCTAssertEqual(field.returnKeyType, .next)
        XCTAssertTrue(field.isSecureTextEntry)
        XCTAssertTrue(chainedTextView === textView)
        XCTAssertEqual(textView.text, "Notes")
        XCTAssertEqual(textView.keyboardType, .asciiCapable)
        XCTAssertEqual(textView.returnKeyType, .done)
        XCTAssertFalse(textView.isEditable)
        XCTAssertFalse(textView.isSelectable)
        XCTAssertTrue(field.delegate === delegate)
        XCTAssertTrue(textView.delegate === delegate)

        host.rootView.addSubview(field)
        host.rootView.addSubview(textView)
        XCTAssertTrue(field.becomeFirstResponder())
        XCTAssertTrue(field.isEditing)
        XCTAssertEqual(delegate.beginCount, 1)

        textView.isEditable(true)
        XCTAssertTrue(textView.becomeFirstResponder())
        XCTAssertFalse(field.isEditing)
        XCTAssertEqual(delegate.beginCount, 2)
    }

    func testTextViewSizeFollowsScrollingPolicy() {
        let host = LayoutTestHost(size: CGSize(width: 200, height: 640))
        let growing = UITextView().text("Short").isScrollEnabled(false)
        pinTop(growing, in: host)
        let shortHeight = growing.frame.height

        growing.text(longText)
        host.layout()

        XCTAssertEqual(growing.frame.width, 200)
        XCTAssertGreaterThan(growing.frame.height, shortHeight * 3)

        growing.removeFromSuperview()
        let scrolling = UITextView().text(longText).isScrollEnabled(true).frame(height: 100)
        pinTop(scrolling, in: host)

        XCTAssertEqual(scrolling.frame.height, 100)
        XCTAssertGreaterThan(scrolling.contentSize.height, 100)
    }

    func testTextStyleFollowsContentSizeCategory() throws {
        guard #available(iOS 17.0, *) else {
            throw XCTSkip("Trait overrides need iOS 17.")
        }
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let field = UITextField().text("Body").font(textStyle: .body)
        let textView = UITextView().text("Body").isScrollEnabled(false).font(textStyle: .body)
        let stack = VStack(alignment: .fill) {
            field
            textView
        }
        pinTop(stack, in: host)
        host.setPreferredContentSizeCategory(.large)
        let fieldSize = field.font!.pointSize
        let textViewSize = textView.font!.pointSize
        let textViewHeight = textView.frame.height

        host.setPreferredContentSizeCategory(.accessibilityExtraLarge)

        XCTAssertGreaterThan(field.font!.pointSize, fieldSize)
        XCTAssertGreaterThan(textView.font!.pointSize, textViewSize)
        XCTAssertGreaterThan(textView.frame.height, textViewHeight)
    }
}
