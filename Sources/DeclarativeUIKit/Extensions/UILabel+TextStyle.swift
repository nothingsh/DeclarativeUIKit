import UIKit

/// Line height and kerning kept on a label, so that the library's text and
/// font modifiers can apply them again to new text.
private struct LabelTextStyle {
    var lineHeight: CGFloat?
    var kerning: CGFloat?
}

private nonisolated(unsafe) var labelTextStyleKey: UInt8 = 0

@MainActor
public extension UILabel {

    /// Sets the height of each line, like the line height in a design tool.
    /// Text sits at the bottom of each line, as UIKit draws it. The height is
    /// relative to the font, so it scales when Dynamic Type changes the font.
    ///
    /// The `text`, `attributedText` and `font` modifiers apply it again;
    /// assigning those properties directly does not.
    @discardableResult
    func lineHeight(_ value: CGFloat) -> Self {
        textStyle.lineHeight = value
        applyTextStyle()
        return self
    }

    /// Adds `value` points of space after each character.
    ///
    /// The `text`, `attributedText` and `font` modifiers apply it again;
    /// assigning those properties directly does not.
    @discardableResult
    func kerning(_ value: CGFloat) -> Self {
        textStyle.kerning = value
        applyTextStyle()
        return self
    }
}

extension UILabel {

    private var textStyle: LabelTextStyle {
        get { objc_getAssociatedObject(self, &labelTextStyleKey) as? LabelTextStyle ?? LabelTextStyle() }
        set { objc_setAssociatedObject(self, &labelTextStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Writes the kept line height and kerning into the current text.
    func applyTextStyle() {
        let style = textStyle
        guard style.lineHeight != nil || style.kerning != nil,
              let current = attributedText, current.length > 0 else { return }
        let styled = NSMutableAttributedString(attributedString: current)
        let range = NSRange(location: 0, length: styled.length)
        if let lineHeight = style.lineHeight {
            let multiple = lineHeight / font.lineHeight
            styled.enumerateAttribute(.paragraphStyle, in: range) { value, paragraphRange, _ in
                let paragraph = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                    ?? NSMutableParagraphStyle()
                paragraph.lineHeightMultiple = multiple
                styled.addAttribute(.paragraphStyle, value: paragraph, range: paragraphRange)
            }
        }
        if let kerning = style.kerning {
            styled.addAttribute(.kern, value: kerning, range: range)
        }
        attributedText = styled
    }
}
