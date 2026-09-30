import UIKit

@MainActor
public extension UITextView {

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
