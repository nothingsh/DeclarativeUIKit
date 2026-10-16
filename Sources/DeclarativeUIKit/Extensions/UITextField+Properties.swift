import UIKit

@MainActor
public extension UITextField {

    @discardableResult
    func text(_ value: String?) -> Self {
        self.text = value
        return self
    }

    @discardableResult
    func attributedText(_ value: NSAttributedString?) -> Self {
        self.attributedText = value
        return self
    }

    @discardableResult
    func placeholder(_ value: String?) -> Self {
        self.placeholder = value
        return self
    }

    @discardableResult
    func attributedPlaceholder(_ value: NSAttributedString?) -> Self {
        self.attributedPlaceholder = value
        return self
    }

    @discardableResult
    func borderStyle(_ value: UITextField.BorderStyle) -> Self {
        self.borderStyle = value
        return self
    }

    @discardableResult
    func clearButtonMode(_ value: UITextField.ViewMode) -> Self {
        self.clearButtonMode = value
        return self
    }

    /// Sets a fixed font. It does not follow Dynamic Type unless
    /// `adjustsFontForContentSizeCategory` is enabled for a scaled font.
    @discardableResult
    func font(_ value: UIFont?) -> Self {
        self.font = value
        return self
    }

    /// Uses the system font for `textStyle` and follows Dynamic Type as the
    /// content size category changes.
    @discardableResult
    func font(textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
        self.adjustsFontForContentSizeCategory = true
        return self
    }

    /// Scales `value` with Dynamic Type the way the system font for `textStyle`
    /// scales, so a custom font follows the content size category. Give the
    /// size the font should have at the default category.
    @discardableResult
    func font(_ value: UIFont, relativeTo textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: value)
        self.adjustsFontForContentSizeCategory = true
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
}
