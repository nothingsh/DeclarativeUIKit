# DeclarativeUIKit

A lightweight declarative layout library for UIKit, built on plain `UIView` and Auto Layout with no third-party dependencies.

It introduces no custom rendering layer and no parallel view hierarchy. What you get back is always a real `UIView` or subclass, so it mixes freely with existing UIKit code.

```swift
let title = UILabel()
title.text = "Profile"

view.addContent(title)
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

## Roadmap

Available today: the Swift package foundation and `addContent` mounting.

Planned: `UIViewBuilder` with `HStack` / `VStack`, property modifiers for common controls, `padding` and `frame`, `padding(safeArea:)`, `background` and `overlay`, `Spacer` and layout priorities, `HScroll` / `VScroll`, and an example app.

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
