# DeclarativeUIKit

A lightweight declarative layout library for UIKit, built on plain `UIView` and Auto Layout with no third-party dependencies.

The goal is a SwiftUI-flavoured way to describe UIKit layouts that introduces no custom rendering layer and no parallel view hierarchy — what you get back is always a real `UIView` or subclass, so it mixes freely with existing UIKit code.

## Status

Early development. This release contains the package skeleton only; no public layout API has shipped yet.

Planned: view mounting, `UIViewBuilder` with `HStack` / `VStack`, property modifiers for common controls, `padding` and `frame`, `padding(safeArea:)`, `background` and `overlay`, `Spacer` and layout priorities, `HScroll` / `VScroll`, and an example app.

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

## Known limitations

The package declares a minimum of iOS 13, but nothing has been built or run against iOS 13 itself — current toolchains no longer support that deployment target. What is verified today is compilation and testing on recent iOS versions.

## Development

The tests exercise UIKit and must run in an iOS Simulator. `swift test` on macOS is not a valid entry point for this library.

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

Use `xcrun simctl list devices available` to find a UDID. Without `IOS_SIMULATOR_ID` the script lists the installed devices and exits. It forwards any extra `xcodebuild` arguments, and writes logs and test results to `.build/validation/`.

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
