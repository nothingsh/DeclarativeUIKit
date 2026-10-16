import UIKit

@MainActor
public extension UITextView {

    @discardableResult
    func text(_ value: String?) -> Self {
        self.text = value
        updatePlaceholder()
        return self
    }

    @discardableResult
    func attributedText(_ value: NSAttributedString?) -> Self {
        self.attributedText = value
        updatePlaceholder()
        return self
    }

    /// Sets a fixed font. It does not follow Dynamic Type unless
    /// `adjustsFontForContentSizeCategory` is enabled for a scaled font.
    @discardableResult
    func font(_ value: UIFont?) -> Self {
        self.font = value
        updatePlaceholder()
        return self
    }

    /// Uses the system font for `textStyle` and follows Dynamic Type as the
    /// content size category changes.
    @discardableResult
    func font(textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
        self.adjustsFontForContentSizeCategory = true
        updatePlaceholder()
        return self
    }

    /// Scales `value` with Dynamic Type the way the system font for `textStyle`
    /// scales, so a custom font follows the content size category. Give the
    /// size the font should have at the default category.
    @discardableResult
    func font(_ value: UIFont, relativeTo textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: value)
        self.adjustsFontForContentSizeCategory = true
        updatePlaceholder()
        return self
    }

    /// Sets the space around the text. The placeholder moves with the text.
    @discardableResult
    func textContainerInset(_ value: UIEdgeInsets) -> Self {
        self.textContainerInset = value
        updatePlaceholder()
        return self
    }

    @discardableResult
    func textColor(_ value: UIColor?) -> Self {
        self.textColor = value
        return self
    }

    @discardableResult
    func textAlignment(_ value: NSTextAlignment) -> Self {
        self.textAlignment = value
        updatePlaceholder()
        return self
    }

    @discardableResult
    func keyboardType(_ value: UIKeyboardType) -> Self {
        self.keyboardType = value
        return self
    }

    @discardableResult
    func returnKeyType(_ value: UIReturnKeyType) -> Self {
        self.returnKeyType = value
        return self
    }

    @discardableResult
    func isSecureTextEntry(_ value: Bool) -> Self {
        self.isSecureTextEntry = value
        return self
    }

    @discardableResult
    func autocapitalizationType(_ value: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = value
        return self
    }

    @discardableResult
    func autocorrectionType(_ value: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = value
        return self
    }

    /// Tells the keyboard what the text is, so it can suggest it or fill it in, such as
    /// an email address, a password or a one-time code.
    @discardableResult
    func textContentType(_ value: UITextContentType?) -> Self {
        self.textContentType = value
        return self
    }

    @discardableResult
    func isEditable(_ value: Bool) -> Self {
        self.isEditable = value
        return self
    }

    @discardableResult
    func isSelectable(_ value: Bool) -> Self {
        self.isSelectable = value
        return self
    }

    /// `false` makes the text view as tall as its text at the width it is
    /// given, like a multiline label. `true`, UIKit's default, gives it no
    /// intrinsic height: size it from outside and the text scrolls inside.
    @discardableResult
    func isScrollEnabled(_ value: Bool) -> Self {
        self.isScrollEnabled = value
        return self
    }
}
