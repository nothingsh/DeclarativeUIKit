import DeclarativeUIKit
import UIKit

// Small styling helpers shared by the example screens. They are plain functions
// over the library's public modifiers, not part of the library.

extension UIStackView {

    /// Pads the stack and puts a rounded card behind it.
    func card(padding: CGFloat = 16) -> Self {
        self.padding(padding)
            .background {
                UIView()
                    .background(.secondarySystemGroupedBackground)
                    .cornerRadius(12)
            }
    }
}

@MainActor
func sectionTitle(_ text: String) -> UILabel {
    UILabel()
        .text(text.uppercased())
        .font(textStyle: .footnote)
        .textColor(.secondaryLabel)
}

@MainActor
func note(_ text: String) -> UILabel {
    UILabel()
        .text(text)
        .font(textStyle: .footnote)
        .textColor(.secondaryLabel)
        .numberOfLines(0)
}

/// The root of every screen: a vertical scroll view with fixed padding.
///
/// The scroll view fills the display from top to bottom and stays inside the safe area at
/// the sides, clear of the sensor housing. UIKit insets the content by the navigation bar
/// and the home indicator, so the content starts below the bar and scrolls under it.
extension UIViewController {

    @discardableResult
    func addScreen(spacing: CGFloat = 16, @UIViewBuilder content: () -> [UIView]) -> VScroll {
        view.background(.systemGroupedBackground)
        return view.addVScroll(alignment: .fill, spacing: spacing, safeArea: .horizontal, content: content)
            .contentInsetAdjustmentBehavior(.automatic)
            .padding(16)
    }
}
