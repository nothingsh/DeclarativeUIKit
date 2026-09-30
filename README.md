# DeclarativeUIKit

A lightweight declarative layout library for UIKit, built on plain `UIView` and Auto Layout with no third-party dependencies.

It introduces no custom rendering layer and no parallel view hierarchy. What you get back is always a real `UIView` or subclass, so it mixes freely with existing UIKit code.

```swift
let name = UILabel()
name.text = "Ada Lovelace"

let role = UILabel()
role.text = "Mathematician"

view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

## Requirements

- iOS 13.0+
- Swift 5.9+
- No external dependencies, system UIKit only

## Installation

Swift Package Manager. In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<owner>/DeclarativeUIKit.git", from: "0.1.0")
]
```

Or in Xcode, File → Add Package Dependencies. No remote version has been published yet; for now, reference it as a local package.

## Usage

### `addContent(_:)`

Mounts a view into a parent and makes it fill that parent.

```swift
@discardableResult
func addContent<Content: UIView>(_ content: Content) -> Content
```

```swift
let label = view.addContent(UILabel())   // returns the UILabel, ready to configure
view.addContent(customView)              // the return value can be ignored
```

- Pins all four edges of the content to the parent's edges, so it always fills the bounds.
- Uses `leadingAnchor` and `trailingAnchor`, so the layout mirrors in right-to-left languages.
- Returns the same instance that was passed in, keeping its concrete type.
- Applies no safe-area inset. Safe-area avoidance is a separate structural modifier — see [Roadmap](#roadmap).
- Leaves the content's own size constraints untouched.

A view is meant to be mounted once. Calling this again for content that already has a superview logs a note through `NSLog`, removes the content from its current parent — which drops the constraints tying it to the old hierarchy — and mounts it again. Constraints never accumulate, but the content moves to the front of the subview order.

Structural modifiers are composed before mounting, as in `view.addContent(card.padding(16))`. Wrapping a view that is already mounted is not supported.

### Stacks

`HStack` and `VStack` arrange views along an axis. Both are `UIStackView` subclasses, so every native stack API stays available.

```swift
init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @UIViewBuilder content: () -> [UIView])   // VStack
init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @UIViewBuilder content: () -> [UIView])     // HStack
```

```swift
let column = VStack(alignment: .leading, spacing: 4) {
    name
    role
    HStack(spacing: 8) {
        icon
        detail
    }
}

view.addContent(column)
```

- `alignment` is the cross axis. A `VStack` takes a `HorizontalAlignment` — `leading`, `center`, `trailing`, `fill`. An `HStack` takes a `VerticalAlignment` — `top`, `center`, `bottom`, `firstTextBaseline`, `lastTextBaseline`, `fill`. The baseline cases use UIKit's own baseline alignment. `fill` has no SwiftUI counterpart and stretches every element across the cross axis.
- `spacing` defaults to `nil`, which means `UIStackView.spacingUseSystem`. That is UIKit's system spacing; it is not a pixel-for-pixel match for SwiftUI's contextual spacing. Pass `0` for no spacing.
- `distribution` is UIKit's own default, `.fill`, and is configured with a modifier rather than an initializer argument.
- Constructing a stack does not mount it anywhere, and the elements keep their declaration order.

To build and mount in one step:

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` and `addVStack` take the same parameters as the initializers, mount the new stack through `addContent`, and return it. Like `addContent`, they mount to the parent's edges and apply no safe-area inset.

Stack modifiers return the stack, so it can be configured after construction or after mounting:

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` and `distribution(_:)` work on any `UIStackView`; passing `nil` to `spacing(_:)` restores the system spacing. `alignment(_:)` is defined per direction, so it takes a `VerticalAlignment` on `HStack` and a `HorizontalAlignment` on `VStack`.

### Content closures

Stack content is written with `@UIViewBuilder`, which collects views in declaration order and accepts:

| Form | Example |
| --- | --- |
| A view | `UILabel()` |
| An optional view | `subtitle`, where `subtitle: UILabel?` — `nil` contributes nothing |
| An array of views | `rows`, where `rows: [UIView]` |
| `if` and `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(iOS 14, *) { modernView }` |
| Nothing at all | `VStack {}` |

An expression that is not a `UIView` fails to compile rather than being silently dropped.

A `UIView` belongs to one parent, so the same instance must not appear twice in one content closure. That is a programming error: it traps with a message instead of quietly collapsing into a single element.

## Roadmap

Available today: the Swift package foundation, `addContent` mounting, and `UIViewBuilder` with `HStack` and `VStack`.

Planned: property modifiers for common controls, `padding` and `frame`, `padding(safeArea:)`, `background` and `overlay`, `Spacer` and layout priorities, `HScroll` / `VScroll`, and an example app.

The API may change before 1.0.

## Known limitations

The package declares a minimum of iOS 13 and new APIs are reviewed for iOS 13 availability, but nothing has been built or run against iOS 13 itself — current toolchains no longer support that deployment target. What is verified today is compilation and testing on recent iOS versions.

## Development

The tests exercise UIKit and must run in an iOS Simulator. `swift test` on macOS is not a valid entry point for this library.

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

Use `xcrun simctl list devices available` to find a UDID. Without `IOS_SIMULATOR_ID` the script lists the installed devices and exits. It forwards any extra `xcodebuild` arguments, and writes logs and test results to `.build/validation/`.

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
