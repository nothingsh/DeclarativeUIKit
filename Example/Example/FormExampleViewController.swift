import DeclarativeUIKit
import UIKit

/// A form whose controls are configured with modifiers, with events handled by
/// `onEvent` closures. The page makes room for the keyboard.
final class FormExampleViewController: UIViewController {

    private let name = UITextField()
        .placeholder("Name")
        .font(textStyle: .body)
        .borderStyle(.roundedRect)
        .textContentType(.name)
        .returnKeyType(.next)

    private let email = UITextField()
        .placeholder("Email")
        .font(textStyle: .body)
        .borderStyle(.roundedRect)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .autocapitalizationType(.none)
        .autocorrectionType(.no)
        .returnKeyType(.next)

    // Not scrollable, so it is as tall as its text and grows while you type.
    private let notes = UITextView()
        .placeholder("Notes grow with their text")
        .font(textStyle: .body)
        .isScrollEnabled(false)
        .frame(minHeight: 44)
        .configure {
            $0.layer.cornerRadius = 6
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.separator.cgColor
        }

    private let newsletter = UISwitch().isOn(true)

    private let frequency = UISlider()
        .minimumValue(1)
        .maximumValue(7)
        .value(3)

    private let frequencyValue = UILabel()
        .font(textStyle: .body)
        .textColor(.secondaryLabel)

    private let submit = UIButton(configuration: .filled())
        .title("Submit")
        .buttonSize(.large)
        .cornerStyle(.large)
        .isEnabled(false)

    private let result = UILabel()
        .font(textStyle: .footnote)
        .textColor(.secondaryLabel)
        .numberOfLines(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Form"
        // The return key moves to the next input.
        name.onEvent(.editingDidEndOnExit) { [weak self] _ in self?.email.becomeFirstResponder() }
        email.onEvent(.editingDidEndOnExit) { [weak self] _ in self?.notes.becomeFirstResponder() }
        name.onEvent(.editingChanged) { [weak self] _ in self?.inputChanged() }
        email.onEvent(.editingChanged) { [weak self] _ in self?.inputChanged() }
        frequency.onEvent(.valueChanged) { [weak self] _ in self?.frequencyChanged() }
        submit.onEvent(.primaryActionTriggered) { [weak self] _ in self?.submitForm() }
        frequencyChanged()

        addScreen {
            sectionTitle("Contact")
            VStack(alignment: .fill, spacing: 12) {
                name
                email
                notes
            }
            .card()

            sectionTitle("Preferences")
            VStack(alignment: .fill, spacing: 12) {
                HStack(spacing: 8) {
                    UILabel()
                        .text("Newsletter")
                        .font(textStyle: .body)
                        .numberOfLines(0)
                    Spacer()
                    newsletter
                }
                HStack(spacing: 8) {
                    UILabel()
                        .text("Issues per week")
                        .font(textStyle: .body)
                        .numberOfLines(0)
                    Spacer()
                    frequencyValue
                }
                frequency
            }
            .card()

            submit
            result
            note("Submit is enabled once name and email are filled in. Return moves to the next input; drag the page to dismiss the keyboard.")
        }
        .alwaysBounceVertical(true)
        .avoidsKeyboard(true)
        .configure { $0.keyboardDismissMode = .onDrag }
    }

    private func inputChanged() {
        submit.isEnabled(!(name.text ?? "").isEmpty && !(email.text ?? "").isEmpty)
    }

    private func frequencyChanged() {
        frequency.value(frequency.value.rounded())
        frequencyValue.text("\(Int(frequency.value))")
    }

    private func submitForm() {
        view.endEditing(true)
        result.text("""
            Saved \(name.text ?? "") <\(email.text ?? "")>, \
            newsletter \(newsletter.isOn ? "on" : "off"), \
            \(Int(frequency.value)) per week.
            Notes: \(notes.text ?? "")
            """)
    }
}
