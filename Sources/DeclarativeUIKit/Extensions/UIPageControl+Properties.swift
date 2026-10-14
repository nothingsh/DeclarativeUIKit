import UIKit

@MainActor
public extension UIPageControl {

    @discardableResult
    func numberOfPages(_ value: Int) -> Self {
        self.numberOfPages = value
        return self
    }

    /// Sets the current page without sending `.valueChanged`. UIKit clamps it to the
    /// number of pages, so set `numberOfPages` first.
    @discardableResult
    func currentPage(_ value: Int) -> Self {
        self.currentPage = value
        return self
    }

    @discardableResult
    func hidesForSinglePage(_ value: Bool) -> Self {
        self.hidesForSinglePage = value
        return self
    }

    @discardableResult
    func pageIndicatorTintColor(_ value: UIColor?) -> Self {
        self.pageIndicatorTintColor = value
        return self
    }

    @discardableResult
    func currentPageIndicatorTintColor(_ value: UIColor?) -> Self {
        self.currentPageIndicatorTintColor = value
        return self
    }
}
