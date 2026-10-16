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
                show: ProfileExampleViewController.init
            )
            entry(
                "Form",
                detail: "Text fields, a growing text view, a switch and a slider, wired with onEvent closures and a delegate.",
                show: FormExampleViewController.init
            )
            entry(
                "Scrolling",
                detail: "HScroll rows inside a VScroll, and rows appended at runtime.",
                show: ScrollExampleViewController.init
            )
            entry(
                "List",
                detail: "A grouped VList with reusable rows, updated by passing new data.",
                show: ListExampleViewController.init
            )
        }
    }

    /// A card whose whole area is a button, placed with `overlay`.
    private func entry(_ title: String, detail: String, show screen: @escaping () -> UIViewController) -> UIView {
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
                .onEvent(.primaryActionTriggered) { [weak self] _ in
                    self?.navigationController?.pushViewController(screen(), animated: true)
                }
        }
    }
}
