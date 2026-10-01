# DeclarativeUIKit

**English** | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

A lightweight declarative layout library for UIKit, built on plain `UIView` and Auto Layout with no third-party dependencies.

It introduces no custom rendering layer and no parallel view hierarchy. What you get back is always a real `UIView` or subclass, so it mixes freely with existing UIKit code. See the [example app](#example-app) for screenshots.

Data binding lives in a companion package, [DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine); see [Data binding](#data-binding).

For AppKit, see the sibling package [DeclarativeAppKit](https://github.com/nothingsh/DeclarativeAppKit).

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    UILabel()
        .text("Ada Lovelace")
        .font(textStyle: .headline)
    UILabel()
        .text("Mathematician")
        .font(textStyle: .subheadline)
        .textColor(.secondaryLabel)
}
```

## Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Mounting](#mounting)
  - [Stacks](#stacks)
  - [Property modifiers](#property-modifiers)
  - [Padding and frame](#padding-and-frame)
  - [Background and overlay](#background-and-overlay)
  - [Spacer](#spacer)
  - [Scroll views](#scroll-views)
- [Data binding](#data-binding)
- [Example app](#example-app)
  - [Profile card](#profile-card)
  - [Form](#form)
  - [Scrolling](#scrolling)
- [Known limitations](#known-limitations)
- [Development](#development)
- [License](#license)

## Installation

Requires iOS 13.0+ and Swift 5.9+. Add the package with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.1.0")
]
```

Or in Xcode, choose File → Add Package Dependencies and enter `https://github.com/nothingsh/DeclarativeUIKit`.

## Usage

### Mounting

```swift
view.addContent(page)                          // fills the parent
view.addContent(page, safeArea: .all)          // stays inside the safe area

view.addVStack(spacing: 8, safeArea: .top) {   // builds a stack and mounts it
    title
    body
}
```

`addContent` pins the four edges of a view to its parent and returns the view with its concrete type. The edges named in `safeArea` are pinned to the parent's safe area instead. `addHStack`, `addVStack`, `addHScroll` and `addVScroll` build and mount in one step.

### Stacks

```swift
let column = VStack(alignment: .leading, spacing: 4) {
    name
    role
    if isEditing { field }
    for tag in tags { chip(tag) }
    HStack(spacing: 8) {
        icon
        detail
    }
}
```

- `HStack` and `VStack` are `UIStackView` subclasses, so every native stack API stays available. Constructing one does not mount it.
- `alignment` is the cross axis: `leading`, `center`, `trailing` or `fill` for a `VStack`; `top`, `center`, `bottom`, `firstTextBaseline`, `lastTextBaseline` or `fill` for an `HStack`. `fill` stretches every element.
- `spacing` defaults to `0`, so the gaps you see are the ones you write. `.spacing(_:)`, `.alignment(_:)` and `.distribution(_:)` change a stack afterwards.
- A content closure accepts views, optional views, arrays, `if` / `else`, `switch`, `for` and `if #available`.

### Property modifiers

Each modifier sets a UIKit property and returns the view as `Self`, so a chain keeps its concrete type.

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)                   // follows Dynamic Type
    .numberOfLines(0)

let play = UIButton(type: .system)
    .title("Play")
    .title("Pause", for: .selected)

let avatar = UIImageView()
    .image(photo)
    .configure { $0.layer.cornerRadius = 24 }   // anything without a modifier
```

| Type | Modifiers |
| --- | --- |
| `UIView` and any subclass | `configure`, `alpha`, `isHidden`, `isUserInteractionEnabled`, `contentMode`, `tintColor`, `clipsToBounds`, `accessibilityLabel`, `accessibilityIdentifier` |
| `UILabel` | `text`, `attributedText`, `font`, `font(textStyle:)`, `textColor`, `numberOfLines`, `textAlignment`, `lineBreakMode` |
| `UIImageView` | `image`, `highlightedImage` |
| `UIControl` and any subclass | `isEnabled`, `isSelected`, `isHighlighted` |
| `UIButton` | `title`, `titleColor`, `image`, `backgroundImage`, each with `for state: UIControl.State = .normal` |
| `UISwitch` | `isOn`, `onTintColor` |
| `UISlider` | `value`, `minimumValue`, `maximumValue`, `minimumTrackTintColor`, `maximumTrackTintColor` |
| `UITextField` | `text`, `attributedText`, `placeholder`, `font`, `font(textStyle:)`, `textColor`, `textAlignment`, `keyboardType`, `returnKeyType`, `isSecureTextEntry` |
| `UITextView` | `text`, `attributedText`, `font`, `font(textStyle:)`, `textColor`, `textAlignment`, `keyboardType`, `returnKeyType`, `isSecureTextEntry`, `isEditable`, `isSelectable`, `isScrollEnabled` |

`font(textStyle:)` follows Dynamic Type, while `font(_:)` sets a fixed font. Button modifiers set one value per control state. Events stay UIKit's own target–action and delegates.

### Padding and frame

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)                // every edge
.padding(.horizontal, 24)   // only the named edges

stack.padding(horizontal: 16, vertical: 12)
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)

let avatar = UIImageView().frame(width: 48, height: 48)
let button = UIButton().frame(minWidth: 88)
let banner = UIImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- `padding` is a stack modifier. It is a fixed distance on every edge, counts toward the stack's size and never includes the safe area. To pad a single view, put it in a stack.
- `frame` adds required size constraints to any view. A later call for the same axis replaces the earlier one.

### Background and overlay

```swift
let badge = UILabel().text("New").background(.systemYellow)          // the view's own background color

let card = VStack { name }
    .padding(16)
    .background { UIView().background(.secondarySystemBackground) }  // any view behind a stack

// in front of a view, nudged out of its corner
let avatar = UIImageView()
    .frame(width: 48, height: 48)
    .overlay(alignment: .bottomTrailing, offset: CGPoint(x: 4, y: 4)) { statusDot }
```

- `background(_:)` sets the view's own `backgroundColor`. A stack does not draw it on iOS 13, so give a stack a colored view with `background { ... }` instead.
- A view decoration is a subview pinned with constraints; no container view is inserted and there is no `ZStack`. `alignment` is `.fill` by default, or a position such as `.topTrailing`.
- The decorated view's own content decides its size.
- `offset` moves a decoration from where `alignment` puts it: x is positive toward the right and y toward the bottom. The value is passed to Auto Layout as it is: in a right-to-left layout a leading or trailing alignment reverses the horizontal direction and the centered ones do not, so adjust it yourself if that is not what you want. `.fill` takes no offset.

### Spacer

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

A `Spacer` takes the remaining length along the axis of its stack, and several spacers share it equally. `contentHuggingPriority(_:for:)` and `compressionResistancePriority(_:for:)` choose which of the other views grows or shrinks first.

### Scroll views

```swift
view.addVScroll(alignment: .fill, spacing: 12) {
    title
    HScroll(spacing: 8, showsIndicators: false) {
        for name in tagNames { chip(name) }
    }
    body
}
.padding(16)
```

- `HScroll` and `VScroll` are `UIScrollView` subclasses that arrange their elements with an embedded stack, available as `stack`. The elements decide the content size; on the other axis the content matches the scroll view.
- Nested in a stack, an `HScroll` takes its height from its elements but needs its width from outside, and a `VScroll` the reverse: use `.fill` alignment, as above, or `frame`.
- `contentInsetAdjustmentBehavior` is `.never`, so the content starts at the scroll view's edges. Mount the scroll view with `safeArea` to keep it inside the safe area.

## Data binding

DeclarativeUIKit lays views out and stops there: a content closure runs once, and the library has no binding of its own. A view that changes later, or that reports events, has to be kept in a property and wired by hand.

[DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine) is the companion package that removes that step. It provides Combine publishers for UIKit controls, scroll views and gestures, and modifiers that bind a view to a publisher in the place where the view is declared:

```swift
view.addVStack(alignment: .fill, spacing: 12) {
    UILabel()
        .font(textStyle: .body)
        .bind(\.text, to: viewModel.$title)

    UIButton(type: .system)
        .title("Submit")
        .bind(\.isEnabled, to: viewModel.$canSubmit)
        .sink(\.tapPublisher) { [weak self] in self?.submit() }
}
```

It is optional and separate. DeclarativeUIKit does not depend on it, and it does not depend on DeclarativeUIKit; add both packages to use them together. Its example app rebuilds the [Form](#form) screen below without keeping a single view in a property.

## Example app

`Example/Example.xcodeproj` is a small iOS app that uses the library as a local package. Open it in Xcode, choose the `Example` scheme and an iOS Simulator, and run. The snippets below are trimmed from its three screens.

### Profile card

The code has the same shape as the screen. The status badge is attached to the avatar with `overlay`, with no wrapper view or `ZStack`. `bio` and `status` are ordinary properties: the buttons change them directly, and Auto Layout resizes the card. Nothing is rebuilt.

<table>
<tr>
<td>

```swift
VStack(alignment: .leading, spacing: 12) {
    HStack(spacing: 12) {
        UIImageView()
            .image(UIImage(systemName: "person.crop.circle.fill"))
            .tintColor(.systemIndigo)
            .frame(width: 64, height: 64)
            .overlay(alignment: .bottomTrailing) { status }
        VStack(alignment: .leading, spacing: 2) {
            UILabel()
                .text("Ada Lovelace")
                .font(textStyle: .title2)
            UILabel()
                .text("Mathematician · London")
                .font(textStyle: .subheadline)
                .textColor(.secondaryLabel)
        }
        Spacer()
    }
    bio
}
.card()

// Later, from a button's action:
bio.text(Self.longBio)
status.background(.systemGray)
```

</td>
<td width="300">
<img src="docs/images/example-profile.png" width="300" alt="Profile card screen">
</td>
</tr>
</table>

A reusable style is just a function over the modifiers. `card()` is the app's own helper, not part of the library:

```swift
extension UIStackView {
    func card(padding: CGFloat = 16) -> Self {
        self.padding(padding)
            .background {
                UIView()
                    .background(.secondarySystemGroupedBackground)
                    .configure { $0.layer.cornerRadius = 12 }
            }
    }
}
```

### Form

The controls are plain `UITextField`, `UISwitch` and `UISlider`, configured with modifiers and kept as properties. Events use UIKit's own target–action and delegates. `Spacer` pushes the switch and the value to the trailing edge.

<table>
<tr>
<td>

```swift
private let newsletter = UISwitch().isOn(true)

private let frequency = UISlider()
    .minimumValue(1)
    .maximumValue(7)
    .value(3)

// In viewDidLoad:
frequency.addTarget(self, action: #selector(frequencyChanged),
                    for: .valueChanged)

VStack(alignment: .fill, spacing: 12) {
    HStack(spacing: 8) {
        UILabel()
            .text("Newsletter")
            .font(textStyle: .body)
        Spacer()
        newsletter
    }
    HStack(spacing: 8) {
        UILabel()
            .text("Issues per week")
            .font(textStyle: .body)
        Spacer()
        frequencyValue
    }
    frequency
}
.card()
```

</td>
<td width="300">
<img src="docs/images/example-form.png" width="300" alt="Form screen">
</td>
</tr>
</table>

### Scrolling

`HScroll` rows inside a `VScroll`. Content closures accept `for` loops, and small functions that return a `UIView` compose like any other view. Tapping *Add row* appends to a stack kept as a property, and the scroll view's content size follows.

<table>
<tr>
<td>

```swift
HScroll(spacing: 8, showsIndicators: false) {
    for tag in Self.tags { chip(tag) }
}

HScroll(alignment: .top, spacing: 12) {
    for index in 1...8 { card(index) }
}

rows

private func chip(_ text: String) -> UIView {
    VStack {
        UILabel()
            .text(text)
            .font(textStyle: .subheadline)
            .textColor(.systemBlue)
    }
    .padding(horizontal: 12, vertical: 6)
    .background {
        UIView()
            .background(UIColor.systemBlue.withAlphaComponent(0.12))
            .configure { $0.layer.cornerRadius = 8 }
    }
}
```

</td>
<td width="300">
<img src="docs/images/example-scroll.png" width="300" alt="Scrolling screen">
</td>
</tr>
</table>

All text uses `font(textStyle:)`, so the screens follow Dynamic Type, and they adapt to rotation. Content closures run once; later changes are made through the views themselves, not through data binding.

Each screen mounts its scroll view with `safeArea: .all`, so content stays clear of the navigation bar, the home indicator and, in landscape, the sensor housing, while the screen's background color still fills the whole display.

The app's deployment target is iOS 15.0, the lowest the current Xcode can build; see [Known limitations](#known-limitations).

## Known limitations

The package declares a minimum of iOS 13 and new APIs are reviewed for iOS 13 availability, but nothing has been built or run against iOS 13 itself — current toolchains no longer support that deployment target. What is verified today is compilation and testing on recent iOS versions.

## Development

The tests exercise UIKit and must run in an iOS Simulator; `swift test` on macOS is not a valid entry point.

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

Use `xcrun simctl list devices available` to find a UDID.

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
