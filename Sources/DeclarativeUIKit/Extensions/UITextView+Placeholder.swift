import UIKit

private nonisolated(unsafe) var placeholderLabelKey: UInt8 = 0

@MainActor
public extension UITextView {

    /// Shows `value` on one line, in the placeholder color, while the text view is
    /// empty. Typing hides and shows it.
    ///
    /// The `text`, `attributedText`, `font`, `textAlignment` and `textContainerInset`
    /// modifiers update it; assigning those properties directly does not.
    @discardableResult
    func placeholder(_ value: String?) -> Self {
        let label = placeholderLabel
        label.isAttributed = false
        label.text = value
        label.textColor = .placeholderText
        updatePlaceholder()
        return self
    }

    /// Shows `value` on one line while the text view is empty, with its own attributes.
    /// Typing hides and shows it.
    @discardableResult
    func attributedPlaceholder(_ value: NSAttributedString?) -> Self {
        let label = placeholderLabel
        label.isAttributed = true
        label.attributedText = value
        updatePlaceholder()
        return self
    }
}

/// The label that shows a text view's placeholder where the first line of text starts.
final class PlaceholderLabel: UILabel {
    /// Whether the text came with its own attributes, so the text view's font is not applied.
    var isAttributed = false
    var top: NSLayoutConstraint!
    var leading: NSLayoutConstraint!
    var trailing: NSLayoutConstraint!

    @objc func textDidChange() {
        (superview as? UITextView)?.updatePlaceholder()
    }
}

@MainActor
extension UITextView {

    private var placeholderLabel: PlaceholderLabel {
        if let label = objc_getAssociatedObject(self, &placeholderLabelKey) as? PlaceholderLabel {
            return label
        }
        let label = PlaceholderLabel()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.top = label.topAnchor.constraint(equalTo: topAnchor).named("placeholder.top")
        label.leading = label.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor).named("placeholder.leading")
        label.trailing = label.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor).named("placeholder.trailing")
        NSLayoutConstraint.activate([label.top, label.leading, label.trailing])
        NotificationCenter.default.addObserver(
            label,
            selector: #selector(PlaceholderLabel.textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        objc_setAssociatedObject(self, &placeholderLabelKey, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return label
    }

    /// Matches the placeholder to the text view's font, alignment and insets, and shows
    /// it only while there is no text.
    func updatePlaceholder() {
        guard let label = objc_getAssociatedObject(self, &placeholderLabelKey) as? PlaceholderLabel else { return }
        if !label.isAttributed, let font {
            label.font = font
        }
        label.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        label.textAlignment = textAlignment
        let padding = textContainer.lineFragmentPadding
        label.top.constant = textContainerInset.top
        label.leading.constant = textContainerInset.left + padding
        label.trailing.constant = -(textContainerInset.right + padding)
        label.isHidden = !text.isEmpty
    }
}
