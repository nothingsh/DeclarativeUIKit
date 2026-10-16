import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class ConstraintNameTests: XCTestCase {

    private func allConstraints(in view: UIView) -> [NSLayoutConstraint] {
        view.constraints + view.subviews.flatMap(allConstraints)
    }

    func testEveryConstraintTheLibraryCreatesIsNamed() {
        let host = LayoutTestHost(size: CGSize(width: 320, height: 640))
        let list = VList([Int](), id: \.self) { ListRow(text: "\($0)") }
            .emptyView(UILabel().text("Empty"))
        host.rootView.addVScroll(alignment: .fill, safeArea: .horizontal) {
            VStack(alignment: .center) {
                UILabel().text("Title")
                Divider()
                UIView().frame(width: 40).frame(minHeight: 20).frame(aspectRatio: 1)
                    .overlay(alignment: .topTrailing) { UIView().frame(width: 8, height: 8) }
                HStack {
                    Spacer(minLength: 4)
                    UILabel().text("Middle")
                    Spacer()
                }
                UITextView().placeholder("Notes").isScrollEnabled(false)
                list.frame(height: 200)
            }
            .padding(16)
            .background { UIView() }
        }
        .fillsViewport(true)
        host.layout()

        // UIKit's own constraints, such as a stack view's, carry UIKit's names or are of
        // UIKit's private classes; every plain constraint left is the library's.
        let unnamed = allConstraints(in: host.rootView).filter {
            type(of: $0) == NSLayoutConstraint.self && $0.identifier == nil
        }
        XCTAssertEqual(unnamed, [])

        let names = Set(allConstraints(in: host.rootView).compactMap(\.identifier))
        for name in ["addContent.top", "scrollContent.width", "fillsViewport", "frame.width",
                     "frame.minHeight", "frame.aspectRatio", "overlay.trailing", "background.leading",
                     "spacer.minLength", "spacer.equalLength", "divider.length", "placeholder.top",
                     "emptyView.centerY"] {
            XCTAssertTrue(names.contains("DeclarativeUIKit.\(name)"), name)
        }
    }
}
