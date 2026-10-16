import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class EventTests: XCTestCase {

    func testOnEventRunsWithTheControlForItsEventsOnly() {
        var received: [UISwitch] = []
        let control = UISwitch().onEvent(.valueChanged) { received.append($0) }

        control.sendActions(for: .touchUpInside)
        XCTAssertTrue(received.isEmpty)

        control.sendActions(for: .valueChanged)
        XCTAssertEqual(received.count, 1)
        XCTAssertTrue(received.first === control)
    }

    // Touches cannot be simulated, so the recognizer's action is invoked directly.
    func testOnTapGestureAddsATapRecognizerThatRunsTheAction() throws {
        var taps = 0
        let label = UILabel().onTapGesture(count: 2) { taps += 1 }

        let recognizer = try XCTUnwrap(label.gestureRecognizers?.first as? UITapGestureRecognizer)
        XCTAssertEqual(recognizer.numberOfTapsRequired, 2)
        XCTAssertTrue(label.isUserInteractionEnabled)

        recognizer.perform(NSSelectorFromString("fire"))
        XCTAssertEqual(taps, 1)
    }

    // UIKit ignores a state set outside touch handling, so the action is sent
    // from a recognizer that reports a fixed state.
    private final class FixedStateRecognizer: UILongPressGestureRecognizer {
        var fixedState = UIGestureRecognizer.State.possible
        override var state: UIGestureRecognizer.State {
            get { fixedState }
            set {}
        }
    }

    func testOnLongPressGestureRunsTheActionOnlyWhenThePressBegins() throws {
        var presses = 0
        let imageView = UIImageView().onLongPressGesture(minimumDuration: 1) { presses += 1 }

        let recognizer = try XCTUnwrap(imageView.gestureRecognizers?.first as? UILongPressGestureRecognizer)
        XCTAssertEqual(recognizer.minimumPressDuration, 1)
        XCTAssertTrue(imageView.isUserInteractionEnabled)

        let sender = FixedStateRecognizer()
        for state in [UIGestureRecognizer.State.began, .changed, .ended] {
            sender.fixedState = state
            recognizer.perform(NSSelectorFromString("fire:"), with: sender)
        }
        XCTAssertEqual(presses, 1)
    }
}
