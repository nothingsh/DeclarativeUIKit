# Building Reusable Components

Reuse a look, a piece of layout or a whole widget with plain Swift functions and views.

## Overview

The library has no component protocol of its own. A component is whichever of three
UIKit-native shapes fits: a function that styles a view, a function that builds one, or a
`UIView` subclass that keeps state. All three mix with the library's modifiers, because
each returns an ordinary view.

### Style an existing view

When several screens share a look, write an extension that applies modifiers and returns
`Self`, as the library's own modifiers do. The caller keeps the concrete type, so more
modifiers can follow.

```swift
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

VStack(alignment: .leading, spacing: 8) {
    title
    body
}
.card()
.shadow(opacity: 0.1, radius: 8)
```

Constrain the extension to the narrowest type that has what it uses: `UIStackView` here,
because `padding` and `background { }` are stack modifiers.

### Build a small view

For a view that is always made the same way, a function that returns it is enough. It
reads like a constructor at the call site, and it takes parameters for what varies.

```swift
@MainActor
func sectionTitle(_ text: String) -> UILabel {
    UILabel()
        .text(text.uppercased())
        .font(textStyle: .footnote)
        .textColor(.secondaryLabel)
}

VStack(alignment: .fill, spacing: 8) {
    sectionTitle("Account")
    accountCard
}
```

The function returns `UILabel`, not `UIView`, so the caller can still change the text or
the color.

### Write a view with state

When a component has parts that change after it is built, subclass `UIView`. Build the
structure once in the initializer with the library, keep the parts that change as
properties, and expose a method that fills them in.

```swift
final class ProfileHeader: UIView {
    private let name = UILabel().font(textStyle: .headline)
    private let role = UILabel().font(textStyle: .subheadline).textColor(.secondaryLabel)
    private let follow = UIButton(configuration: .filled()).title("Follow")

    /// Called when the follow button is tapped.
    var onFollow: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        follow.onEvent(.primaryActionTriggered) { [weak self] _ in self?.onFollow?() }
        addHStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                name
                role
            }
            .accessibilityCombined()
            Spacer()
            follow
        }
        .padding(16)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    func update(name: String, role: String) {
        self.name.text(name)
        self.role.text(role)
    }
}
```

- The view sizes itself from its content with Auto Layout, so it can go into any stack
  without a `frame`.
- Report events through a closure property or a delegate. Capture `self` weakly in
  closures the view keeps, as above, or the view and its owner keep each other alive.
- Keep `update` to plain assignments. It can then run as often as the data changes.
- Declaring `ListRowView` makes the same view a reusable row in a ``VList``, because the
  inherited `init()` meets the protocol:

```swift
extension ProfileHeader: ListRowView {}

VList(people, id: \.id) { person in
    ListRow(ProfileHeader.self) { $0.update(name: person.name, role: person.role) }
}
```

### Add modifiers to your own view

A modifier is a method that sets something and returns `Self`. Mark it
`@discardableResult`, so a call that is not chained compiles without a warning.

```swift
extension ProfileHeader {
    @discardableResult
    func showsFollowButton(_ value: Bool) -> Self {
        follow.isHidden = !value
        return self
    }
}
```

Return the view itself, not a new view that wraps it: a wrapper would hide the view's
type and its other modifiers from the caller.

## Topics

### Types used by components

- ``ListRowView``
- ``ListRow``
