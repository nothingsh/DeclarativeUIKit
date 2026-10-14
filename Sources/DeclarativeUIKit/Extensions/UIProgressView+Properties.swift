import UIKit

@MainActor
public extension UIProgressView {

    /// Sets the progress, from 0 to 1. UIKit clamps values outside that range.
    @discardableResult
    func progress(_ value: Float, animated: Bool = false) -> Self {
        setProgress(value, animated: animated)
        return self
    }

    @discardableResult
    func progressTintColor(_ value: UIColor?) -> Self {
        self.progressTintColor = value
        return self
    }

    @discardableResult
    func trackTintColor(_ value: UIColor?) -> Self {
        self.trackTintColor = value
        return self
    }
}
