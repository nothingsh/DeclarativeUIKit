import UIKit

@MainActor
public extension UILabel {

    @discardableResult
    func text(_ value: String?) -> Self {
        self.text = value
        applyTextStyle()
        return self
    }

    @discardableResult
    func attributedText(_ value: NSAttributedString?) -> Self {
        self.attributedText = value
        applyTextStyle()
        return self
    }

    /// Sets a fixed font. It does not follow Dynamic Type unless
    /// `adjustsFontForContentSizeCategory` is enabled for a scaled font.
    @discardableResult
    func font(_ value: UIFont?) -> Self {
        self.font = value
        applyTextStyle()
        return self
    }

    /// Uses the system font for `textStyle` and follows Dynamic Type as the
    /// content size category changes.
    @discardableResult
    func font(textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
        self.adjustsFontForContentSizeCategory = true
        applyTextStyle()
        return self
    }

    /// Scales `value` with Dynamic Type the way the system font for `textStyle`
    /// scales, so a custom font follows the content size category. Give the
    /// size the font should have at the default category.
    @discardableResult
    func font(_ value: UIFont, relativeTo textStyle: UIFont.TextStyle) -> Self {
        self.font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: value)
        self.adjustsFontForContentSizeCategory = true
        applyTextStyle()
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

    /// Shrinks the font to fit the width, down to `minimumScaleFactor`. A label with
    /// `numberOfLines(0)` takes more lines instead and never shrinks.
    @discardableResult
    func adjustsFontSizeToFitWidth(_ value: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = value
        return self
    }

    @discardableResult
    func minimumScaleFactor(_ value: CGFloat) -> Self {
        self.minimumScaleFactor = value
        return self
    }
}
