import DeclarativeUIKit
import UIKit

/// Horizontal scroll views nested in a vertical one, and rows appended at runtime.
final class ScrollExampleViewController: UIViewController {

    private static let tags = [
        "UIKit", "Auto Layout", "Stacks", "Padding", "Frame", "Background",
        "Overlay", "Spacer", "Scroll", "Dynamic Type", "RTL",
    ]

    private let rows = VStack(alignment: .fill, spacing: 8) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scrolling"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add row", style: .plain, target: self, action: #selector(addRow)
        )
        for _ in 1...12 { addRow() }

        addScreen {
            sectionTitle("Tags · HScroll")
            HScroll(spacing: 8, showsIndicators: false) {
                for tag in Self.tags { chip(tag) }
            }

            sectionTitle("Cards · HScroll")
            HScroll(alignment: .top, spacing: 12) {
                for index in 1...8 { card(index) }
            }

            sectionTitle("Rows · VScroll")
            note("Add row appends to the stack kept as a property; the content size grows with it.")
            rows
        }
    }

    private func chip(_ text: String) -> UIView {
        VStack {
            UILabel()
                .text(text)
                .font(textStyle: .subheadline)
                .textColor(.systemBlue)
        }
        .padding(horizontal: 12, vertical: 6)
        .background {
            UIView()
                .background(UIColor.systemBlue.withAlphaComponent(0.12))
                .configure { $0.layer.cornerRadius = 8 }
        }
    }

    private func card(_ index: Int) -> UIView {
        VStack(alignment: .leading, spacing: 4) {
            UIImageView()
                .image(UIImage(systemName: "square.stack.3d.up.fill"))
                .tintColor(.systemOrange)
                .contentMode(.scaleAspectFit)
                .frame(width: 32, height: 32)
            UILabel()
                .text("Card \(index)")
                .font(textStyle: .headline)
            UILabel()
                .text(index.isMultiple(of: 3) ? "A longer caption that wraps onto a few lines." : "Short caption")
                .font(textStyle: .footnote)
                .textColor(.secondaryLabel)
                .numberOfLines(0)
        }
        .card(padding: 12)
        .frame(width: 160)
    }

    @objc private func addRow() {
        let number = rows.arrangedSubviews.count + 1
        rows.addArrangedSubview(
            HStack(spacing: 8) {
                UILabel()
                    .text("Row \(number)")
                    .font(textStyle: .body)
                Spacer(minLength: 8)
                UILabel()
                    .text(number.isMultiple(of: 2) ? "even" : "odd")
                    .font(textStyle: .body)
                    .textColor(.secondaryLabel)
            }
            .card(padding: 12)
        )
    }
}
