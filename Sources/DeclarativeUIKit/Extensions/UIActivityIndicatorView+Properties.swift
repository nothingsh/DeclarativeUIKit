import UIKit

@MainActor
public extension UIActivityIndicatorView {

    /// Starts or stops the animation.
    @discardableResult
    func isAnimating(_ value: Bool) -> Self {
        if value {
            startAnimating()
        } else {
            stopAnimating()
        }
        return self
    }

    @discardableResult
    func hidesWhenStopped(_ value: Bool) -> Self {
        self.hidesWhenStopped = value
        return self
    }

    @discardableResult
    func color(_ value: UIColor) -> Self {
        self.color = value
        return self
    }
}
