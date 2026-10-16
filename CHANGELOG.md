# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- The minimum deployment target is iOS 15.0, raised from iOS 13.0.

## [0.2.0] - 2026-10-14

### Added

- `offset` for `overlay` and `background` decorations.
- `spacing(_:after:)` on stacks and scroll views, for a different distance after one element.
- `HScroll` and `VScroll` forward every form of `padding`.
- Layer modifiers for any view: `cornerRadius`, `border(color:width:)` and `shadow`.
- Accessibility modifiers: `accessibilityHint`, `accessibilityTraits` and `isAccessibilityElement`.
- `UILabel` modifiers `adjustsFontSizeToFitWidth` and `minimumScaleFactor`.
- `UIImageView` modifier `preferredSymbolConfiguration`.
- Modifiers for `UISegmentedControl`, `UIStepper`, `UIActivityIndicatorView`, `UIProgressView` and `UIPageControl`.
- DocC documentation catalog.

### Fixed

- `configure` on a custom view subclass compiles with Swift 6.1 and earlier, where the closure did not receive the subclass type.
- The remaining spacers in a stack keep sharing the extra space equally after one of them is removed.

## [0.1.0] - 2026-10-01

First release.

[Unreleased]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.2.0...HEAD
[0.2.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/nothingsh/DeclarativeUIKit/releases/tag/0.1.0
