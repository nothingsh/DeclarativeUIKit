import UIKit

@MainActor
public extension UIImageView {

    @discardableResult
    func image(_ value: UIImage?) -> Self {
        self.image = value
        return self
    }

    @discardableResult
    func highlightedImage(_ value: UIImage?) -> Self {
        self.highlightedImage = value
        return self
    }

    /// Sets the configuration used for symbol images, such as their point size, weight
    /// and scale.
    @discardableResult
    func preferredSymbolConfiguration(_ value: UIImage.SymbolConfiguration?) -> Self {
        self.preferredSymbolConfiguration = value
        return self
    }
}
