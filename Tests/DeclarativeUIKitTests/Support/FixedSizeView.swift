import UIKit

/// A plain view whose size is held by required width and height constraints.
@MainActor
func fixedSizeView(width: CGFloat, height: CGFloat) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        view.widthAnchor.constraint(equalToConstant: width),
        view.heightAnchor.constraint(equalToConstant: height)
    ])
    return view
}

@MainActor
func fittingSize(_ view: UIView) -> CGSize {
    view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
}
