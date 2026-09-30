import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class ControlPropertyTests: XCTestCase {

    // The test process has no UIApplication to deliver actions, so dispatch
    // is observed at UIControl's own hook instead of at the target.
    private final class RecordingSwitch: UISwitch {
        var sentActions: [Selector] = []
        override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
            sentActions.append(action)
        }
    }

    private final class RecordingSlider: UISlider {
        var sentActions: [Selector] = []
        override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
            sentActions.append(action)
        }
    }

    @objc private func valueChanged() {}

    func testButtonStateModifiersKeepEachStateSeparate() {
        let playImage = UIImage()
        let pauseImage = UIImage()
        let plate = UIImage()

        let button: UIButton = UIButton(type: .custom)
            .title("Play")
            .title("Pause", for: .selected)
            .title("Unavailable", for: .disabled)
            .titleColor(.blue)
            .titleColor(.red, for: .selected)
            .image(playImage)
            .image(pauseImage, for: .selected)
            .backgroundImage(plate, for: .highlighted)

        XCTAssertEqual(button.title(for: .normal), "Play")
        XCTAssertEqual(button.title(for: .selected), "Pause")
        XCTAssertEqual(button.title(for: .disabled), "Unavailable")
        XCTAssertEqual(button.titleColor(for: .normal), .blue)
        XCTAssertEqual(button.titleColor(for: .selected), .red)
        XCTAssertTrue(button.image(for: .normal) === playImage)
        XCTAssertTrue(button.image(for: .selected) === pauseImage)
        XCTAssertTrue(button.backgroundImage(for: .highlighted) === plate)
        XCTAssertNil(button.backgroundImage(for: .normal))

        let result: UIButton = button.isSelected(true)
        XCTAssertTrue(result === button)
        XCTAssertEqual(button.currentTitle, "Pause")

        button.isSelected(false).isHighlighted(true)
        XCTAssertTrue(button.isHighlighted)
        XCTAssertTrue(button.currentBackgroundImage === plate)

        button.isHighlighted(false).isEnabled(false)
        XCTAssertEqual(button.currentTitle, "Unavailable")
    }

    func testValueModifiersSendNoActionsAndTargetActionStillWorks() {
        let toggle = RecordingSwitch()
        let slider = RecordingSlider()
        let action = #selector(valueChanged)
        toggle.addTarget(self, action: action, for: .valueChanged)
        slider.addTarget(self, action: action, for: .valueChanged)

        let chainedToggle: RecordingSwitch = toggle
            .isOn(true)
            .onTintColor(.orange)
        let chainedSlider: RecordingSlider = slider
            .minimumValue(-5)
            .maximumValue(20)
            .value(15)
            .minimumTrackTintColor(.green)
            .maximumTrackTintColor(.gray)

        XCTAssertTrue(chainedToggle === toggle)
        XCTAssertTrue(toggle.isOn)
        XCTAssertEqual(toggle.onTintColor, .orange)
        XCTAssertTrue(chainedSlider === slider)
        XCTAssertEqual(slider.minimumValue, -5)
        XCTAssertEqual(slider.maximumValue, 20)
        XCTAssertEqual(slider.value, 15)
        XCTAssertEqual(slider.minimumTrackTintColor, .green)
        XCTAssertEqual(slider.maximumTrackTintColor, .gray)
        XCTAssertEqual(toggle.sentActions, [], "Setting a value is not a user event.")
        XCTAssertEqual(slider.sentActions, [], "Setting a value is not a user event.")

        toggle.sendActions(for: .valueChanged)
        slider.sendActions(for: .valueChanged)
        XCTAssertEqual(toggle.sentActions, [action])
        XCTAssertEqual(slider.sentActions, [action])
    }
}
