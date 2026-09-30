import DeclarativeUIKit
import UIKit

/// The list of example screens.
final class ExamplesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DeclarativeUIKit"
        addScreen(spacing: 12) {
            entry(
                "Profile card",
                detail: "Stacks, frame, background, overlay and Dynamic Type. Change a label through its reference and the card resizes.",
                action: #selector(showProfile)
            )
            entry(
                "Form",
                detail: "Text fields, a growing text view, a switch and a slider, wired with UIKit target–action and delegates.",
                action: #selector(showForm)
            )
            entry(
                "Scrolling",
                detail: "HScroll rows inside a VScroll, and rows appended at runtime.",
                action: #selector(showScroll)
            )
        }
    }

    /// A card whose whole area is a button, placed with `overlay`.
    private func entry(_ title: String, detail: String, action: Selector) -> UIView {
        VStack(alignment: .leading, spacing: 4) {
            UILabel()
                .text(title)
                .font(textStyle: .headline)
            UILabel()
                .text(detail)
                .font(textStyle: .subheadline)
                .textColor(.secondaryLabel)
                .numberOfLines(0)
        }
        .card()
        .overlay {
            UIButton(type: .system)
                .accessibilityLabel(title)
                .configure { $0.addTarget(self, action: action, for: .touchUpInside) }
        }
    }

    @objc private func showProfile() {
        navigationController?.pushViewController(ProfileExampleViewController(), animated: true)
    }

    @objc private func showForm() {
        navigationController?.pushViewController(FormExampleViewController(), animated: true)
    }

    @objc private func showScroll() {
        navigationController?.pushViewController(ScrollExampleViewController(), animated: true)
    }
}
