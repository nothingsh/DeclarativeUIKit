import UIKit

private let refreshActionID = UIAction.Identifier("DeclarativeUIKit.onRefresh")

@MainActor
public extension UIScrollView {

    /// Adds pull to refresh. Pulling runs `action`, and the refresh control spins until
    /// `action` returns. Replaces an earlier action. The control is kept in
    /// `refreshControl`; one already there is used.
    @discardableResult
    func onRefresh(_ action: @escaping @MainActor () async -> Void) -> Self {
        let control = refreshControl ?? UIRefreshControl()
        refreshControl = control
        // An action with the same identifier replaces the earlier one.
        control.addAction(UIAction(identifier: refreshActionID) { [weak control] _ in
            Task { @MainActor in
                await action()
                control?.endRefreshing()
            }
        }, for: .valueChanged)
        return self
    }
}
