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
}
