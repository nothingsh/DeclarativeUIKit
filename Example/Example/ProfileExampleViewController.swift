import DeclarativeUIKit
import UIKit

/// A profile card built from stacks, with a status badge placed by `overlay`.
///
/// The content closures run once. Later changes go through the references kept
/// here, and Auto Layout resizes the card; nothing is re-rendered or bound.
final class ProfileExampleViewController: UIViewController {

    private static let shortBio = "Writes about analytical engines."
    private static let longBio = """
        Writes about analytical engines, and about what they could do beyond arithmetic: \
        compose music, draw figures, and manipulate any symbols whose relations can be \
        expressed. Her notes on the engine include what is often called the first published \
        program, a method for computing Bernoulli numbers.
        """

    private let bio = UILabel()
        .text(ProfileExampleViewController.shortBio)
        .font(textStyle: .body)
        .numberOfLines(0)

    private let status = UIView()
        .background(.systemGreen)
        .frame(width: 16, height: 16)
        .configure {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.secondarySystemGroupedBackground.cgColor
        }

    private let bioButton = UIButton(type: .system)
        .title("Show long bio")
        .title("Show short bio", for: .selected)

    private let statusButton = UIButton(type: .system)
        .title("Go away")
        .title("Come back", for: .selected)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile card"
        bioButton.addTarget(self, action: #selector(toggleBio), for: .touchUpInside)
        statusButton.addTarget(self, action: #selector(toggleStatus), for: .touchUpInside)

        addScreen {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    UIImageView()
                        .image(UIImage(systemName: "person.crop.circle.fill"))
                        .tintColor(.systemIndigo)
                        .frame(width: 64, height: 64)
                        .overlay(alignment: .bottomTrailing) { status }
                    VStack(alignment: .leading, spacing: 2) {
                        UILabel()
                            .text("Ada Lovelace")
                            .font(textStyle: .title2)
                            .numberOfLines(0)
                        UILabel()
                            .text("Mathematician · London")
                            .font(textStyle: .subheadline)
                            .textColor(.secondaryLabel)
                            .numberOfLines(0)
                    }
                    Spacer()
                }
                bio
            }
            .card()

            HStack(spacing: 16) {
                bioButton
                statusButton
                Spacer()
            }

            note("""
                The bio label is kept as a property. Its text is changed through that reference, \
                and the card grows or shrinks with it. Rotate the device or change the text size \
                to see the same layout adapt.
                """)
        }
    }

    @objc private func toggleBio() {
        bioButton.isSelected(!bioButton.isSelected)
        bio.text(bioButton.isSelected ? Self.longBio : Self.shortBio)
    }

    @objc private func toggleStatus() {
        statusButton.isSelected(!statusButton.isSelected)
        status.background(statusButton.isSelected ? .systemGray : .systemGreen)
    }
}
