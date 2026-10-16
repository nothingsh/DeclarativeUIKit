<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/declarative-uikit-dark.svg">
    <img src="docs/images/declarative-uikit-light.svg" alt="DeclarativeUIKit — Declarative layout for UIKit, on plain UIView." width="850">
  </picture>
</p>

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
  - [Events](#events)
  - [Padding and frame](#padding-and-frame)
  - [Background and overlay](#background-and-overlay)
  - [Spacer](#spacer)
  - [Scroll views](#scroll-views)
  - [Keyboard](#keyboard)
  - [Lists](#lists)
  - [Xcode previews](#xcode-previews)
- [Data binding](#data-binding)
- [Example app](#example-app)
  - [Profile card](#profile-card)
  - [Form](#form)
  - [Scrolling](#scrolling)
  - [List](#list)
- [Known limitations](#known-limitations)
- [Development](#development)
- [License](#license)

## Installation

Requires iOS 15.0+ and Swift 5.9+. Add the package with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.8.0")
]
```

Or in Xcode, choose File → Add Package Dependencies and enter `https://github.com/nothingsh/DeclarativeUIKit`.

Changes between versions are listed in [CHANGELOG.md](CHANGELOG.md). For the API reference, open the package in Xcode and choose Product → Build Documentation.

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
- `spacing` defaults to `0`, so the gaps you see are the ones you write. `.spacing(_:)`, `.alignment(_:)` and `.distribution(_:)` change a stack afterwards, and `.spacing(_:after:)` sets a different distance after one element.
- A content closure accepts views, optional views, arrays, `if` / `else`, `switch`, `for` and `if #available`.
- A content closure runs once. To show different elements later, keep the stack and call `replaceContent { … }`: the old elements leave the view hierarchy, and a background or overlay stays.

### Property modifiers

Each modifier sets a UIKit property and returns the view as `Self`, so a chain keeps its concrete type.

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)                   // follows Dynamic Type
    .numberOfLines(0)

let body = UILabel()
    .font(UIFont(name: "Avenir-Book", size: 16)!, relativeTo: .body)  // custom font, follows Dynamic Type
    .lineHeight(24)
    .kerning(0.2)
    .numberOfLines(0)
    .text(article.body)

let play = UIButton(type: .system)
    .title("Play")
    .title("Pause", for: .selected)

let save = UIButton(configuration: .filled())
    .title("Save")
    .image(UIImage(systemName: "checkmark"))
    .imagePadding(8)
    .cornerStyle(.capsule)
    .titleFont(textStyle: .headline)            // follows Dynamic Type

let avatar = UIImageView()
    .image(photo)
    .cornerRadius(24)
    .clipsToBounds(true)
    .configure { $0.layer.zPosition = 1 }       // anything without a modifier
```

| Type | Modifiers |
| --- | --- |
| `UIView` and any subclass | `configure`, `alpha`, `isHidden`, `isUserInteractionEnabled`, `contentMode`, `tintColor`, `clipsToBounds`, `accessibilityLabel`, `accessibilityHint`, `accessibilityTraits`, `isAccessibilityElement`, `accessibilityIdentifier`, `cornerRadius`, `cornerRadius(_:corners:)`, `border(color:width:)`, `shadow`, `accessibilityCombined` |
| `UILabel` | `text`, `attributedText`, `font`, `font(textStyle:)`, `font(_:relativeTo:)`, `lineHeight`, `kerning`, `textColor`, `numberOfLines`, `textAlignment`, `lineBreakMode`, `adjustsFontSizeToFitWidth`, `minimumScaleFactor` |
| `UIImageView` | `image`, `highlightedImage`, `preferredSymbolConfiguration` |
| `UIControl` and any subclass | `isEnabled`, `isSelected`, `isHighlighted` |
| `UIButton` | `title`, `titleColor`, `image`, `backgroundImage`, each with `for state: UIControl.State = .normal` |
| `UIButton` with a configuration | `buttonSize`, `cornerStyle`, `contentInsets`, `baseForegroundColor`, `baseBackgroundColor`, `subtitle`, `titleAlignment`, `titlePadding`, `titleFont`, `titleFont(_:relativeTo:)`, `titleFont(textStyle:)`, `imagePlacement`, `imagePadding`, `preferredSymbolConfigurationForImage`, `showsActivityIndicator` |
| `UISwitch` | `isOn`, `onTintColor` |
| `UISlider` | `value`, `minimumValue`, `maximumValue`, `minimumTrackTintColor`, `maximumTrackTintColor` |
| `UIStepper` | `value`, `minimumValue`, `maximumValue`, `stepValue` |
| `UISegmentedControl` | `selectedSegmentIndex`, `selectedSegmentTintColor`, `isMomentary` |
| `UIPageControl` | `numberOfPages`, `currentPage`, `hidesForSinglePage`, `pageIndicatorTintColor`, `currentPageIndicatorTintColor` |
| `UIProgressView` | `progress(_:animated:)`, `progressTintColor`, `trackTintColor` |
| `UIActivityIndicatorView` | `isAnimating`, `hidesWhenStopped`, `color` |
| `UITextField` | `text`, `attributedText`, `placeholder`, `attributedPlaceholder`, `font`, `font(textStyle:)`, `font(_:relativeTo:)`, `textColor`, `textAlignment`, `borderStyle`, `clearButtonMode`, `keyboardType`, `returnKeyType`, `isSecureTextEntry`, `autocapitalizationType`, `autocorrectionType`, `textContentType` |
| `UITextView` | `text`, `attributedText`, `placeholder`, `attributedPlaceholder`, `font`, `font(textStyle:)`, `font(_:relativeTo:)`, `textColor`, `textAlignment`, `textContainerInset`, `keyboardType`, `returnKeyType`, `isSecureTextEntry`, `autocapitalizationType`, `autocorrectionType`, `textContentType`, `isEditable`, `isSelectable`, `isScrollEnabled` |

`font(textStyle:)` follows Dynamic Type, while `font(_:)` sets a fixed font. `font(_:relativeTo:)` makes a custom font follow Dynamic Type the way the system font for the text style does; give the size it should have at the default text size. Button modifiers set one value per control state. Value modifiers such as `value`, `selectedSegmentIndex` and `currentPage` send no `.valueChanged`.

The modifiers for a button with a configuration change its `UIButton.Configuration`, so create the button with `UIButton(configuration:)`; on a button without one they stop with a precondition failure. `title` and `image` work on both kinds of button, per state. On a button with a configuration, color the text with `baseForegroundColor` instead of `titleColor`, and set the background through the configuration's `background` instead of `backgroundImage`. `titleFont` replaces the configuration's `titleTextAttributesTransformer`; the `relativeTo:` and `textStyle:` forms follow Dynamic Type.

`lineHeight` sets the height of each line, as in a design tool, and `kerning` the space after each character. `UILabel` has no property for either, so the label keeps them and writes them into `attributedText`. The `text`, `attributedText` and `font` modifiers apply them again; assigning `label.text = …` directly does not, so update the text with `label.text(…)`. Text sits at the bottom of each line, as UIKit draws it, not centered as in a design tool. The line height is relative to the font, so it grows with Dynamic Type.

`UITextView` has no placeholder of its own. `placeholder` and `attributedPlaceholder` show one line where the text starts while the text view is empty, in the placeholder color unless the attributed form sets its own. Typing hides and shows it, and the `text`, `attributedText`, `font`, `textAlignment` and `textContainerInset` modifiers update it; assigning `textView.text = …` directly does not.

`cornerRadius`, `border` and `shadow` set the view's layer. `cornerRadius` does not clip: add `clipsToBounds(true)`, which also cuts off a shadow. `corners` rounds only some corners, named as physical corners such as `.layerMinXMinYCorner` for the top left, so they do not mirror in right-to-left languages. Border and shadow colors follow a switch between light and dark mode: the view gets a hidden subview that resolves them again when the appearance changes. Assigning `layer.borderColor` directly is not followed.

`accessibilityCombined()` makes VoiceOver read a view and its descendants as one element, whose label joins the labels of the visible descendants and follows later changes. Only labels are combined, so do not use it on an area with buttons or other controls.

### Events

`onEvent` runs a closure each time a control sends one of the given `UIControl.Event`s. The closure receives the control as its own type, so it can read `isOn`, `value` or `text` without the control being kept in a property. `onTapGesture` and `onLongPressGesture` work on any view.

```swift
UISwitch()
    .onEvent(.valueChanged) { [weak self] toggle in
        self?.settings.isEnabled = toggle.isOn
    }

UIButton(type: .system)
    .title("Save")
    .onEvent(.primaryActionTriggered) { [weak self] _ in self?.save() }

UIImageView(image: avatar)
    .onTapGesture { [weak self] in self?.showProfile() }
    .onLongPressGesture { [weak self] in self?.showMenu() }
```

- Each gesture modifier adds a recognizer and turns on `isUserInteractionEnabled`, which `UILabel` and `UIImageView` leave off. `onTapGesture(count:perform:)` needs one tap by default. `onLongPressGesture(minimumDuration:perform:)` runs its closure once, when the press has lasted `minimumDuration`, 0.5 seconds by default.
- Each call adds another action or recognizer; earlier ones stay. To stop them, turn the control or view off with `isEnabled` or `isUserInteractionEnabled`.
- The control keeps its closures, and the view keeps its recognizers and their closures. Capture a view controller with `[weak self]`, or it and the view keep each other alive.
- Delegates, such as `UITextFieldDelegate`, are set as usual.

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

- `background(_:)` sets the view's own `backgroundColor`, which a stack draws too. `background { ... }` puts a whole view behind a stack instead.
- `GradientView([.systemTeal, .systemBlue])` draws a linear gradient, top to bottom by default; use it with `background { … }`. Its points are unit coordinates, as in `CAGradientLayer`, and its colors follow dark mode.
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

`Divider()` is a hairline across its stack: horizontal in a `VStack` and vertical in an `HStack`. It spans the stack inside its padding, whatever the alignment, in `.separator`; change the color with `background(_:)`.

```swift
VStack(alignment: .leading, spacing: 12) {
    header
    Divider()
    body
}
.padding(16)
```

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
- `alignment`, `spacing`, `spacing(_:after:)`, `replaceContent` and every form of `padding` are forwarded to `stack`; the padding lies inside the scrolled content.
- `contentInsetAdjustmentBehavior` is `.never`, so the content starts at the scroll view's edges. Mount the scroll view with `safeArea` to keep it inside the safe area.
- `isPagingEnabled` and `keyboardDismissMode` set those properties. `onRefresh { await … }` adds pull to refresh: the refresh control spins until the closure returns. Another call replaces the action.
- Short content keeps its own length, so a `Spacer` along the scrolling axis has no room to take. `fillsViewport(true)` makes the content at least as tall as a `VScroll`, or as wide as an `HScroll`; a `Spacer` then takes the extra length, which keeps a button at the bottom of a short form, while longer content still scrolls:

```swift
view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    form
    Spacer()
    submit
}
.fillsViewport(true)
```

- To let content scroll under a translucent navigation bar, pin the scroll view to the safe area only at the sides and let UIKit inset the content by the bars. The content starts below the bar, and the bar shows its background once content scrolls under it. `fillsViewport` and `avoidsKeyboard` take these insets into account:

```swift
view.addVScroll(alignment: .fill, spacing: 12, safeArea: .horizontal) {
    form
}
.contentInsetAdjustmentBehavior(.automatic)
```

### Keyboard

```swift
let email = UITextField()
    .placeholder("Email")
    .textContentType(.emailAddress)
    .returnKeyType(.next)
    .onEvent(.editingDidEndOnExit) { _ in password.becomeFirstResponder() }  // return moves to the next input

view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    email
    password
    notes
}
.avoidsKeyboard(true)
```

- `avoidsKeyboard(true)` works on any `UIScrollView`, including `VScroll`, `VList` and a scrolling `UITextView`. While the keyboard covers part of the scroll view, the covered height is added to the bottom content and scroll indicator insets, and the input being edited is scrolled above the keyboard. Insets you set yourself are kept. It is off by default.
- Only the covered part counts: a scroll view that ends above the keyboard is not changed, and a floating keyboard on iPad covers nothing.
- Views outside a scroll view do not move. Put a button that must stay reachable at the end of the scroll view's content.
- A text field sends `.editingDidEndOnExit` when return is pressed, so `onEvent` can move to the next input without a delegate.

### Lists

`VList` is a vertical list that creates rows as they scroll into view and updates them by diffing. It is a `UICollectionView` with UIKit's list layout and a diffable data source; the library adds only the row declarations.

```swift
final class OrderRow: UIView, ListRowView {
    private let title = UILabel().font(textStyle: .headline)
    private let price = UILabel().font(textStyle: .body)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addHStack(spacing: 12) {
            title
            Spacer()
            price
        }
        .padding(horizontal: 16, vertical: 12)
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(_ order: Order) {
        title.text(order.title)
        price.text(order.price)
    }
}

let orders = view.addContent(VList<Order>(id: \.id) { [weak self] order in
    ListRow(OrderRow.self) { $0.update(order) }
        .accessories([.disclosureIndicator()])
        .onSelect { self?.show(order) }
}, safeArea: .all)

orders.update(firstPage)
orders.update(firstPage + secondPage)
```

- `update` inserts, removes and moves rows by `id`, animated by default. Every row whose id is in both the old and the new data is configured again, so `Item` need not be `Equatable`. Ids must be unique across the whole list.
- `ListRow(OrderRow.self) { … }` is a reusable row. The list creates the view with `init()`, once per cell, and calls the closure each time the row is shown or its item changes; keep the closure to plain assignments. The view never sees an item when it is created, so no item's data can stick to a view that is reused for another item.
- `ListRow { … }` rebuilds its view every time. It suits static rows such as an app version; a row with controls or frequent updates should be reusable, since rebuilding loses control state.
- `accessories` takes UIKit's `UICellAccessory` values. Only rows with `onSelect` highlight; after the action runs, the row is deselected.
- Rows fill the cell and size themselves with Auto Layout. The list adds no padding of its own, so each row sets its own.
- For grouped screens, pass `sections:` and an `appearance` such as `.insetGrouped`. A `ListSection` takes an `id` and optional `header` and `footer` text, shown in UIKit's default style.

```swift
let settings = VList(
    sections: [
        ListSection(id: "general", header: "General", items: [Setting.account, .notifications]),
        ListSection(id: "about", items: [Setting.version])
    ],
    id: \.self,
    appearance: .insetGrouped
) { setting in
    ListRow { SettingRow(setting) }
}
```

- `listConfiguration` adjusts UIKit's `UICollectionLayoutListConfiguration` for every section. The separators start where the system puts them, which varies by iOS version and device; to line them up with your rows' padding, set `separatorConfiguration` there.
- Like the scroll views, `VList` uses `contentInsetAdjustmentBehavior = .never`; mount it with `safeArea`.
- The list is its own `delegate`, for selection. Replacing the delegate stops `onSelect`.
- The list keeps the row closure, and each cell keeps its `onSelect` action. Capture a view controller with `[weak self]`, or it and the list keep each other alive.
- With [DeclarativeCombine](#data-binding), `onReceive` feeds a publisher into `update`: `list.onReceive(viewModel.$orders) { $0.update($1) }`.

Rows in UIKit's standard style, swipe actions, loading more and an empty state:

```swift
let list = VList(orders, id: \.id) { [weak self] order in
    ListRow(text: order.title, secondaryText: order.date, image: UIImage(systemName: "bag"))
        .trailingSwipeActions([
            UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
                self?.delete(order)
                done(true)
            }
        ])
}
.emptyView(UILabel().text("No orders").textColor(.secondaryLabel))
.onReachEnd { [weak self] in self?.loadNextPage() }
.onRefresh { [weak self] in await self?.reload() }

list.scrollTo(order.id)
```

- `ListRow(text:secondaryText:image:)` is a row in UIKit's standard style, laid out by the cell's default content configuration for the list's appearance, with the separator lined up with the text. `ListRow(content:)` takes any `UIListContentConfiguration`, such as `.valueCell()` for text on both sides.
- `leadingSwipeActions` and `trailingSwipeActions` take UIKit's `UIContextualAction`s, and each handler must call its completion handler. With `allowsFullSwipe`, on by default, a full swipe runs the first action. `listConfiguration` cannot change the swipe actions.
- `onReachEnd` runs when the last row is about to be shown. That includes a new last row after an update and the last row scrolled back into view, so ignore calls while a page is loading.
- `scrollTo` scrolls to the row with an id, only as far as needed unless you pass a position such as `.top`. The id must be in the list.
- `emptyView` is shown in the middle of the list while it has no rows, even if it has section headers. `offset` moves it from the middle, with x positive toward the right and y toward the bottom, as for `overlay`. It is kept in `backgroundView`.
- `onRefresh` works on any scroll view; see [Scroll views](#scroll-views).

### Xcode previews

Xcode 15 and later preview a UIKit view directly. The `#Preview` macro for UIKit needs iOS 17, so in a target that supports older versions, mark the preview with `@available(iOS 17, *)`. Only the preview needs iOS 17; the rest of the code keeps its deployment target.

```swift
@available(iOS 17, *)
#Preview {
    VStack(alignment: .leading, spacing: 4) {
        UILabel().text("Ada Lovelace").font(textStyle: .headline)
        UILabel().text("Mathematician").textColor(.secondaryLabel)
    }
    .padding(16)
}
```

## Data binding

DeclarativeUIKit lays views out and stops there: a content closure runs once, and the library has no binding of its own. A view that changes later has to be kept in a property and updated by hand.

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

`Example/Example.xcodeproj` is a small iOS app that uses the library as a local package. Open it in Xcode, choose the `Example` scheme and an iOS Simulator, and run. The snippets below are trimmed from its four screens.

### Profile card

The code has the same shape as the screen. The status badge is attached to the avatar with `overlay`, with no wrapper view or `ZStack`. `bio` and `status` are ordinary properties: the buttons change them directly, and Auto Layout resizes the card. Nothing is rebuilt. A `Divider` separates the header from the bio, and `accessibilityCombined` lets VoiceOver read the name and role as one element.

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
    .accessibilityCombined()
    Divider()
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
                    .cornerRadius(12)
            }
    }
}
```

### Form

The controls are plain `UITextField`, `UISwitch` and `UISlider`, configured with modifiers and kept as properties. Events are handled with `onEvent` closures; the return key moves to the next input. The page makes room for the keyboard with `avoidsKeyboard`, and the notes view shows a placeholder. `Spacer` pushes the switch and the value to the trailing edge.

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
frequency.onEvent(.valueChanged) { [weak self] _ in
    self?.frequencyChanged()
}

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

### List

An `.insetGrouped` `VList` with a header and footer. `MessageRow` and `SwitchRow` are reusable rows; the storage row is a standard row and the version row is rebuilt each time. *Add*, tapping a message, swiping it to delete it and pulling to refresh change the data and call `update`, which inserts the new row with animation, refreshes the changed row and the unread count in the header.

<table>
<tr>
<td>

```swift
VList(sections: sections(), id: \.id, appearance: .insetGrouped) { [weak self] row in
    switch row {
    case .message(let message):
        return ListRow(MessageRow.self) { $0.update(message) }
            .onSelect { self?.toggleRead(message.id) }
            .trailingSwipeActions([
                UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
                    self?.deleteMessage(message.id)
                    done(true)
                }
            ])
    case .notifications:
        return ListRow(SwitchRow.self) {
            $0.update(title: "Notifications", isOn: self?.notifications ?? false)
            $0.onChange = { self?.notifications = $0 }
        }
    case .storage:
        var content = UIListContentConfiguration.valueCell()
        content.text = "Storage"
        content.secondaryText = "1.2 GB"
        content.image = UIImage(systemName: "internaldrive")
        return ListRow(content: content)
    case .version:
        return ListRow {
            HStack(spacing: 8) {
                UILabel().text("Version").font(textStyle: .body)
                Spacer()
                UILabel().text("1.0").font(textStyle: .body).textColor(.secondaryLabel)
            }
            .padding(horizontal: 16, vertical: 12)
        }
    }
}

private func toggleRead(_ id: Int) {
    guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
    messages[index].isRead.toggle()
    list.update(sections())
}
```

</td>
<td width="300">
<img src="docs/images/example-list.png" width="300" alt="List screen">
</td>
</tr>
</table>

All text uses `font(textStyle:)`, so the screens follow Dynamic Type, and they adapt to rotation. Content closures run once; later changes are made through the views themselves, not through data binding.

Each screen pins its scroll view to the safe area only at the sides and lets UIKit inset the content by the navigation bar and the home indicator. Content starts below the bar and scrolls under it, stays clear of the sensor housing in landscape, and the screen's background color fills the whole display.

The app's deployment target is iOS 15.0, the same as the package's.

## Known limitations

`VScroll` and `HScroll` are not lazy: every element is created and laid out up front. They suit pages and short lists; for long or data-driven lists, use [`VList`](#lists).

## Development

The tests exercise UIKit and must run in an iOS Simulator; `swift test` on macOS is not a valid entry point.

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

Use `xcrun simctl list devices available` to find a UDID.

## License

[MIT](LICENSE), Copyright (c) 2026 Wynn.
