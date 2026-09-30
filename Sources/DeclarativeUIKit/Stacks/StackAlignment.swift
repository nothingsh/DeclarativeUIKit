import UIKit

/// Cross-axis alignment of the elements in a `VStack`.
public enum HorizontalAlignment {
    case leading
    case center
    case trailing
    /// A UIKit addition with no SwiftUI counterpart: every element is stretched
    /// to the stack's width.
    case fill

    var stackAlignment: UIStackView.Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        case .fill: return .fill
        }
    }
}

/// Cross-axis alignment of the elements in an `HStack`.
///
/// The baseline cases use UIKit's own baseline alignment; they are not SwiftUI's
/// alignment guides.
public enum VerticalAlignment {
    case top
    case center
    case bottom
    case firstTextBaseline
    case lastTextBaseline
    /// A UIKit addition with no SwiftUI counterpart: every element is stretched
    /// to the stack's height.
    case fill

    var stackAlignment: UIStackView.Alignment {
        switch self {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        case .firstTextBaseline: return .firstBaseline
        case .lastTextBaseline: return .lastBaseline
        case .fill: return .fill
        }
    }
}
