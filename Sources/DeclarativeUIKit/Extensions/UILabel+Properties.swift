import UIKit

@MainActor
public extension UILabel {

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

    /// `0` allows as many lines as the text needs.
    @discardableResult
    func numberOfLines(_ value: Int) -> Self {
        self.numberOfLines = value
        return self
    }

    @discardableResult
    func textAlignment(_ value: NSTextAlignment) -> Self {
        self.textAlignment = value
        return self
    }

    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode) -> Self {
        self.lineBreakMode = value
        return self
    }
}
