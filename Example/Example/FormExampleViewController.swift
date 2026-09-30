import DeclarativeUIKit
import UIKit

/// A form whose controls are configured with modifiers and wired with UIKit's own
/// target–action and delegates.
final class FormExampleViewController: UIViewController, UITextFieldDelegate {

    private let name = UITextField()
        .placeholder("Name")
        .font(textStyle: .body)
        .returnKeyType(.next)
        .configure { $0.borderStyle = .roundedRect }

    private let email = UITextField()
        .placeholder("Email")
        .font(textStyle: .body)
        .keyboardType(.emailAddress)
        .returnKeyType(.done)
        .configure {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }

    // Not scrollable, so it is as tall as its text and grows while you type.
    private let notes = UITextView()
        .text("Notes grow with their text, because scrolling is off.")
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

    private let submit = UIButton(type: .system)
        .title("Submit")
        .titleColor(.tertiaryLabel, for: .disabled)
        .isEnabled(false)

    private let result = UILabel()
        .font(textStyle: .footnote)
        .textColor(.secondaryLabel)
        .numberOfLines(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Form"
        name.delegate = self
        email.delegate = self
        name.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        email.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        frequency.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        submit.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
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
            note("Submit is enabled once name and email are filled in. The keyboard is UIKit's own; drag the page to dismiss it.")
        }
        .alwaysBounceVertical(true)
        .configure { $0.keyboardDismissMode = .onDrag }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === name {
            email.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func inputChanged() {
        submit.isEnabled(!(name.text ?? "").isEmpty && !(email.text ?? "").isEmpty)
    }

    @objc private func frequencyChanged() {
        frequency.value(frequency.value.rounded())
        frequencyValue.text("\(Int(frequency.value))")
    }

    @objc private func submitForm() {
        view.endEditing(true)
        result.text("""
            Saved \(name.text ?? "") <\(email.text ?? "")>, \
            newsletter \(newsletter.isOn ? "on" : "off"), \
            \(Int(frequency.value)) per week.
            Notes: \(notes.text ?? "")
            """)
    }
}
