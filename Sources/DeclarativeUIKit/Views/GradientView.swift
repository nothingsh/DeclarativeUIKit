import UIKit

/// A view that draws a linear gradient, for use as a background.
///
/// Points are in the unit coordinate space of `CAGradientLayer`: (0, 0) is the top left
/// and (1, 1) the bottom right. Dynamic colors follow changes between light and dark mode.
public final class GradientView: UIView {

    private let colors: [UIColor]

    public override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    /// - Parameters:
    ///   - colors: The colors, in order from `startPoint` to `endPoint`.
    ///   - startPoint: Where the gradient starts. The top center by default.
    ///   - endPoint: Where the gradient ends. The bottom center by default.
    ///   - locations: Where each color is fully reached, from 0 to 1. Evenly spaced by default.
    public init(
        _ colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1),
        locations: [CGFloat]? = nil
    ) {
        self.colors = colors
        super.init(frame: .zero)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = locations?.map { NSNumber(value: Double($0)) }
        applyColors()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("GradientView is built in code and does not support init(coder:).")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyColors()
    }

    private func applyColors() {
        gradientLayer.colors = colors.map { $0.resolvedColor(with: traitCollection).cgColor }
    }
}
