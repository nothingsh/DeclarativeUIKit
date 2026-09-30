import UIKit
import XCTest
@testable import DeclarativeUIKit

@MainActor
final class BuilderTests: XCTestCase {

    /// Evaluates builder content on its own, so these assertions describe the
    /// builder rather than any container that consumes it.
    private func build(@UIViewBuilder _ content: () -> [UIView]) -> [UIView] {
        content()
    }

    func testEmptyContentProducesNoViews() {
        XCTAssertTrue(build {}.isEmpty)
    }

    func testEverySupportedFormKeepsDeclarationOrder() {
        let single = UIView()
        let present: UIView? = UIView()
        let absent: UIView? = nil
        let pair = [UIView(), UIView()]
        let taken = UILabel()
        let skipped = UILabel()
        let matched = UIView()
        let unmatched = UIView()
        let looped = [UIView(), UIView(), UIView()]
        let guarded = UIView()
        let nested = HStack { UIView() }
        let condition = pair.count == 2
        let key = "b"

        let result = build {
            single
            present
            absent
            pair
            if condition {
                taken
            } else {
                skipped
            }
            switch key {
            case "a":
                unmatched
            default:
                matched
            }
            for view in looped {
                view
            }
            if #available(iOS 14, *) {
                guarded
            }
            nested
        }

        let expected = [single, present!] + pair + [taken, matched] + looped + [guarded, nested]
        XCTAssertEqual(
            result.map(ObjectIdentifier.init),
            expected.map(ObjectIdentifier.init)
        )
    }
}
