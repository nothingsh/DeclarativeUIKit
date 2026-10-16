import UIKit

/// Each modifier changes one property of the button's `configuration`, so the
/// button must have one: create it with `UIButton(configuration:)`.
/// `title(_:for:)` and `image(_:for:)` also apply to such a button.
@MainActor
public extension UIButton {

    // MARK: Size and shape

    @discardableResult
    func buttonSize(_ value: UIButton.Configuration.Size) -> Self {
        updateConfiguration { $0.buttonSize = value }
    }

    @discardableResult
    func cornerStyle(_ value: UIButton.Configuration.CornerStyle) -> Self {
        updateConfiguration { $0.cornerStyle = value }
    }

    @discardableResult
    func contentInsets(_ value: NSDirectionalEdgeInsets) -> Self {
        updateConfiguration { $0.contentInsets = value }
    }

    // MARK: Colors

    /// The color of the title, subtitle and image. Use it instead of
    /// `titleColor(_:for:)` on a button with a configuration.
    @discardableResult
    func baseForegroundColor(_ value: UIColor?) -> Self {
        updateConfiguration { $0.baseForegroundColor = value }
    }

    @discardableResult
    func baseBackgroundColor(_ value: UIColor?) -> Self {
        updateConfiguration { $0.baseBackgroundColor = value }
    }

    // MARK: Text

    @discardableResult
    func subtitle(_ value: String?) -> Self {
        updateConfiguration { $0.subtitle = value }
    }

    @discardableResult
    func titleAlignment(_ value: UIButton.Configuration.TitleAlignment) -> Self {
        updateConfiguration { $0.titleAlignment = value }
    }

    /// The space between the title and the subtitle.
    @discardableResult
    func titlePadding(_ value: CGFloat) -> Self {
        updateConfiguration { $0.titlePadding = value }
    }

    /// Sets a fixed title font. It replaces the configuration's
    /// `titleTextAttributesTransformer`.
    @discardableResult
    func titleFont(_ value: UIFont) -> Self {
        setTitleFont { _ in value }
    }

    /// Scales `value` with Dynamic Type the way the system font for `textStyle`
    /// scales. Give the size the font should have at the default category.
    /// It replaces the configuration's `titleTextAttributesTransformer`.
    @discardableResult
    func titleFont(_ value: UIFont, relativeTo textStyle: UIFont.TextStyle) -> Self {
        setTitleFont { traits in
            UIFontMetrics(forTextStyle: textStyle).scaledFont(for: value, compatibleWith: traits)
        }
    }

    /// Uses the system font for `textStyle` and follows Dynamic Type. It
    /// replaces the configuration's `titleTextAttributesTransformer`.
    @discardableResult
    func titleFont(textStyle: UIFont.TextStyle) -> Self {
        setTitleFont { traits in
            UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: traits)
        }
    }

    // MARK: Image

    @discardableResult
    func imagePlacement(_ value: NSDirectionalRectEdge) -> Self {
        updateConfiguration { $0.imagePlacement = value }
    }

    /// The space between the image and the text.
    @discardableResult
    func imagePadding(_ value: CGFloat) -> Self {
        updateConfiguration { $0.imagePadding = value }
    }

    @discardableResult
    func preferredSymbolConfigurationForImage(_ value: UIImage.SymbolConfiguration?) -> Self {
        updateConfiguration { $0.preferredSymbolConfigurationForImage = value }
    }

    // MARK: State

    /// Shows an activity indicator in place of the image.
    @discardableResult
    func showsActivityIndicator(_ value: Bool) -> Self {
        updateConfiguration { $0.showsActivityIndicator = value }
    }
}

@MainActor
private extension UIButton {

    func updateConfiguration(_ change: (inout UIButton.Configuration) -> Void) -> Self {
        guard var configuration else {
            preconditionFailure("This modifier needs a button created with UIButton(configuration:).")
        }
        change(&configuration)
        self.configuration = configuration
        return self
    }

    /// The transformer runs again when the traits change, so a font computed
    /// from the button's current traits follows Dynamic Type. It holds the
    /// button weakly, because the button holds the transformer.
    func setTitleFont(_ font: @escaping (UITraitCollection?) -> UIFont) -> Self {
        updateConfiguration { configuration in
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] attributes in
                var attributes = attributes
                attributes[AttributeScopes.UIKitAttributes.FontAttribute.self] = font(self?.traitCollection)
                return attributes
            }
        }
    }
}
