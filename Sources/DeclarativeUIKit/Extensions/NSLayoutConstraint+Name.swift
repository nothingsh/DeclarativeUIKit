import UIKit

extension NSLayoutConstraint {

    /// Names a constraint the library creates, `DeclarativeUIKit.` followed by `name`, so
    /// that a layout conflict in the console shows which modifier made it.
    func named(_ name: String) -> NSLayoutConstraint {
        identifier = "DeclarativeUIKit.\(name)"
        return self
    }
}
