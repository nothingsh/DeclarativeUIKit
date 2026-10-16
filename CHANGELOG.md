# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `Divider`, a hairline across the stack it is in.
- `GradientView`, a view that draws a linear gradient.
- `cornerRadius(_:corners:curve:)`, which rounds only the given corners.
- `accessibilityCombined()`, which makes VoiceOver read a view and its descendants as one element.

### Changed

- The colors of `border` and `shadow` follow changes between light and dark mode, instead of being resolved once.
- `fillsViewport` counts only the length inside `adjustedContentInset`, so content can scroll under a translucent navigation bar and still fill exactly one screen, and a bottom element pushed down by a `Spacer` stays above the keyboard with `avoidsKeyboard`.
- `avoidsKeyboard` no longer counts the bottom safe area twice when UIKit already insets the content by it.
- `VStack` and `HStack` arrange their elements inside zero layout margins from the start; padding still only changes those margins.

## [0.7.0] - 2026-10-16

### Added

- `ListRow(text:secondaryText:image:)` and `ListRow(content:)`, rows in UIKit's standard style.
- `leadingSwipeActions` and `trailingSwipeActions` on `ListRow`.
- `onReachEnd`, `scrollTo(_:at:animated:)` and `emptyView(_:offset:)` on `VList`.
- `onRefresh`, `isPagingEnabled` and `keyboardDismissMode` on any `UIScrollView`.

## [0.6.0] - 2026-10-16

### Added

- `avoidsKeyboard(_:)` on any `UIScrollView`, which adds the height the keyboard covers to the bottom insets and scrolls the input being edited above the keyboard.
- `placeholder(_:)` and `attributedPlaceholder(_:)` on `UITextView`, shown while the text view is empty.
- `autocapitalizationType`, `autocorrectionType` and `textContentType` on `UITextField` and `UITextView`; `attributedPlaceholder`, `borderStyle` and `clearButtonMode` on `UITextField`; `textContainerInset` on `UITextView`.

## [0.5.0] - 2026-10-16

### Added

- `lineHeight(_:)` and `kerning(_:)` on `UILabel`, kept across the label's `text`, `attributedText` and `font` modifiers.
- `font(_:relativeTo:)` on `UILabel`, `UITextField` and `UITextView`, which makes a custom font follow Dynamic Type.
- Modifiers for buttons created with `UIButton(configuration:)`: `buttonSize`, `cornerStyle`, `contentInsets`, `baseForegroundColor`, `baseBackgroundColor`, `subtitle`, `titleAlignment`, `titlePadding`, `titleFont`, `imagePlacement`, `imagePadding`, `preferredSymbolConfigurationForImage` and `showsActivityIndicator`.

## [0.4.0] - 2026-10-16

### Added

- `onEvent(_:perform:)` on any `UIControl`, which runs a closure with the control each time one of the given events fires.
- `onTapGesture(count:perform:)` and `onLongPressGesture(minimumDuration:perform:)` on any view.
- `replaceContent` on stacks, `HScroll` and `VScroll`, which replaces the elements with new builder content.
- `fillsViewport(_:)` on `VScroll` and `HScroll`, which makes short content at least as long as the scroll view.

## [0.3.0] - 2026-10-16

### Added

- `VList`, a vertical list that creates rows lazily and updates them by diffing, with `ListRow`, `ListRowView` and `ListSection`.

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

[Unreleased]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.7.0...HEAD
[0.7.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/nothingsh/DeclarativeUIKit/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/nothingsh/DeclarativeUIKit/releases/tag/0.1.0
