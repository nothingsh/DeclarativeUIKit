# DeclarativeUIKit

A lightweight declarative layout library for UIKit, built on plain `UIView` and Auto Layout with no third-party dependencies.

It introduces no custom rendering layer and no parallel view hierarchy. What you get back is always a real `UIView` or subclass, so it mixes freely with existing UIKit code.

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

Mounts a view into a parent and makes it fill that parent, or the parent's safe area on the edges you choose.

```swift
@discardableResult
func addContent<Content: UIView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(UILabel())   // returns the UILabel, ready to configure
view.addContent(customView)              // the return value can be ignored
view.addContent(page, safeArea: .all)    // stays inside the safe area
```

- By default pins all four edges of the content to the parent's edges, so it fills the bounds and ignores the safe area.
- The edges named in `safeArea` are pinned to the parent's `safeAreaLayoutGuide` instead. The content, including any background it draws, stays inside the safe area on those edges and follows it as it changes, for example on rotation. Name only some edges to let the others reach the parent's edges: `safeArea: .horizontal` keeps content clear of the sensor housing in landscape but lets it run under the status bar.
- Uses `leadingAnchor` and `trailingAnchor`, so the layout mirrors in right-to-left languages. `LayoutEdges` is the same option set that `padding` uses.
- Returns the same instance that was passed in, keeping its concrete type.
- Leaves the content's own size constraints untouched.

A view is meant to be mounted once. Calling this again for content that already has a superview logs a note through `NSLog`, removes the content from its current parent — which drops the constraints tying it to the old hierarchy — and mounts it again. Constraints never accumulate, but the content moves to the front of the subview order.

### Stacks

`HStack` and `VStack` arrange views along an axis. Both are `UIStackView` subclasses, so every native stack API stays available.

```swift
init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0, @UIViewBuilder content: () -> [UIView])   // VStack
init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0, @UIViewBuilder content: () -> [UIView])     // HStack
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
- `spacing` defaults to `0`, as in `UIStackView`, so the gaps you see are the ones you write. This differs from SwiftUI, whose default spacing is contextual.
- `distribution` is UIKit's own default, `.fill`, and is configured with a modifier rather than an initializer argument.
- Constructing a stack does not mount it anywhere, and the elements keep their declaration order.

To build and mount in one step:

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` and `addVStack` take the same parameters as the initializers plus `safeArea`, mount the new stack through `addContent`, and return it. As with `addContent`, the stack fills the parent unless you name safe-area edges:

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

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

`spacing(_:)` and `distribution(_:)` work on any `UIStackView`. `alignment(_:)` is defined per direction, so it takes a `VerticalAlignment` on `HStack` and a `HorizontalAlignment` on `VStack`.

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

### Property modifiers

Property modifiers set a UIKit property on the receiver and return the same instance as `Self`, so the concrete type survives the chain and type-specific modifiers stay available after general ones. When the same property is set twice, the last call wins.

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)
    .numberOfLines(0)
    .accessibilityIdentifier("title")

title.text("Updated")   // later updates go through the same reference
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

Each modifier takes the same type as the UIKit property it sets. They are not an exhaustive mirror of UIKit; for anything else, use `configure`, which hands you the view with its concrete type:

```swift
let avatar = UIImageView()
    .image(photo)
    .contentMode(.scaleAspectFill)
    .clipsToBounds(true)
    .configure { $0.layer.cornerRadius = 24 }
```

- `font(textStyle:)` uses the system font for that text style and turns on `adjustsFontForContentSizeCategory`, so the label follows Dynamic Type. `font(_:)` only sets the font, exactly like the UIKit property.
- `numberOfLines(0)` lets a label wrap; under Auto Layout its height follows the available width.

Button modifiers set one value per control state, through UIKit's `setTitle(_:for:)` and its siblings, so the states never overwrite each other. A state without its own value falls back to `.normal`, as in UIKit. The library doesn't use `UIButton.Configuration`.

```swift
let play = UIButton(type: .system)
    .title("Play")
    .title("Pause", for: .selected)
    .image(playIcon)
    .image(pauseIcon, for: .selected)

let volume = UISlider()
    .minimumValue(0)
    .maximumValue(10)
    .value(7)
```

- Events use UIKit's own target–action: `play.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)`. The modifiers add no targets and no closure handlers.
- Setting a value with `isOn` or `value` is not a user event and sends no `.valueChanged`, as with the UIKit properties.
- `UISlider` clamps `value` to its current range, so set `minimumValue` and `maximumValue` before `value`.

Text input modifiers configure `UITextField` and `UITextView` the same way; `font(textStyle:)` follows Dynamic Type as it does for labels.

```swift
let email = UITextField()
    .placeholder("Email")
    .keyboardType(.emailAddress)
    .returnKeyType(.next)
    .font(textStyle: .body)

let notes = UITextView()
    .text(draft)
    .font(textStyle: .body)
    .isScrollEnabled(false)
```

- `placeholder` exists only on `UITextField`, because `UITextView` has no placeholder in UIKit and the library doesn't add one.
- A text view's size depends on `isScrollEnabled`. With `false`, it is as tall as its text at the width it is given, and grows as the text grows, like a multiline label. With `true`, UIKit's default, it has no intrinsic height: give it one with `frame` or constraints, and longer text scrolls inside it.
- Delegates, editing and the keyboard stay UIKit's own. The modifiers set no delegate, and there is no two-way binding, input validation or keyboard avoidance.

### Padding

Padding is a stack modifier. It sets the stack's `directionalLayoutMargins`, turns on `isLayoutMarginsRelativeArrangement` and turns off `insetsLayoutMarginsFromSafeArea`, then returns the same stack.

```swift
func padding(_ length: CGFloat) -> Self
func padding(_ edges: LayoutEdges = .all, _ length: CGFloat = 16) -> Self
func padding(horizontal: CGFloat, vertical: CGFloat) -> Self
func padding(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) -> Self
func padding(_ edges: LayoutEdges, _ length: CGFloat, others: CGFloat) -> Self
func padding(_ insets: NSDirectionalEdgeInsets) -> Self
```

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(.horizontal, 16)
.padding(.vertical, 12)
```

```swift
stack.padding(horizontal: 16, vertical: 12)                   // one value per axis
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // every edge differs
stack.padding(.top, 24, others: 8)                            // one edge, the rest alike
```

- Padding counts toward the stack's size: a stack whose content is 20 × 30 is 40 × 50 with `.padding(10)`.
- It behaves like a property. `padding(_:_:)` changes only the edges you name and keeps the others, so `.padding(.horizontal, 16).padding(.vertical, 12)` sets all four. Every other form sets all four edges in one call. A later call replaces earlier values rather than adding to them.
- `LayoutEdges` is an option set of `top`, `leading`, `bottom`, `trailing`, plus `horizontal`, `vertical` and `all`. Horizontal edges are `leading` and `trailing`, so they mirror in right-to-left languages.
- Padding is fixed spacing and never includes the safe area. To keep content inside the safe area, mount it with `safeArea`; see [`addContent(_:)`](#addcontent_).
- To pad a single view, put it in a stack: `VStack { label }.padding(16)`.

### Frame

`frame` adds size constraints to the view itself and returns it as `Self`, so the chain keeps its concrete type. As in SwiftUI, there is one form for a fixed size and one for a size range.

```swift
func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self
func frame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil,
           minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self
func frame(aspectRatio: CGFloat?) -> Self
```

```swift
let avatar = UIImageView()
    .frame(width: 48, height: 48)
    .image(photo)
    .contentMode(.scaleAspectFill)

let button = UIButton().frame(minWidth: 88)
let label = UILabel().frame(maxWidth: 200)
let banner = UIImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- It sets `translatesAutoresizingMaskIntoConstraints` to `false` and uses required `widthAnchor` / `heightAnchor` constraints: `==` for a fixed length, `>=` for a minimum, `<=` for a maximum.
- Each call redefines the axes it names and leaves the other axis alone. Calling `frame(width: 100)` and then `frame(width: 120)` updates the same constraint. A fixed width removes an earlier minimum or maximum width, and a range removes an earlier fixed width, so switching between them never conflicts. In the range form, naming only one bound of an axis removes the other: `frame(minWidth: 40)` after `frame(maxWidth: 200)` leaves only the minimum.
- `.infinity` is accepted as a maximum and means no upper bound; it adds no constraint.
- `frame(aspectRatio:)` keeps width equal to the ratio times height, as in SwiftUI (`16 / 9` is wider than tall). Pair it with a fixed width or height to derive the other length; fixing both as well conflicts. A repeated call replaces the ratio, and `nil` removes it.
- Only the constraints `frame` created are updated or removed. Size constraints you add yourself are never touched.
- A negative or non-finite fixed length or minimum, a negative or NaN maximum, or a minimum above the maximum, or an aspect ratio that is not finite and positive is a programming error and traps with a message.

### Background and overlay

`background(_:)` sets the view's own `backgroundColor`. A view decoration is added as a subview of the view it decorates and pinned with constraints. Every form returns the same view as `Self`. No container view is inserted and there is no `ZStack`.

```swift
// UIView
func background(_ color: UIColor?) -> Self
func overlay(alignment: LayoutAlignment = .fill, content: () -> UIView) -> Self

// UIStackView
func background(alignment: LayoutAlignment = .fill, content: () -> UIView) -> Self
```

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)
.background { UIView().background(.secondarySystemBackground) }

let title = UILabel().text("New").background(.systemYellow)

let avatar = UIImageView()
    .frame(width: 48, height: 48)
    .image(photo)
    .overlay(alignment: .bottomTrailing) {
        UIView().background(.systemGreen).frame(width: 12, height: 12)
    }
```

- `background(_:)` works on any view and only sets `backgroundColor`; it is the library's modifier for that property. A stack doesn't draw its `backgroundColor` on iOS 13; to support iOS 13, give a stack a colored view with `background { ... }` instead.
- `background { ... }` is a stack modifier. The view goes behind the stack's content and, with the default `.fill`, covers the whole stack, padding included. To put a background view behind a single view, put that view in a stack: `VStack { label }.padding(8).background { badgeShape }`.
- `overlay` works on any view and goes in front of the view's current subviews and, with the default `.fill`, covers the whole view. Subviews added later, such as arranged subviews appended afterwards, go in front of it.
- The decorated view's content decides its size. With `.fill`, the decoration's hugging and compression resistance are set to `.fittingSizeLevel`, so a large image can't enlarge the view. A decoration whose own subviews require a minimum size, such as a stack of labels, still can.
- `LayoutAlignment` is `fill`, `center`, `top`, `bottom`, `leading`, `trailing`, `topLeading`, `topTrailing`, `bottomLeading` or `bottomTrailing`. `fill` stretches the decoration over the view. The other cases keep the decoration's own size and place it at that position. `leading` and `trailing` mirror in right-to-left languages.
- View decorations add up, as in SwiftUI: a later `background { ... }` goes further back, and a later `overlay` goes further front.
- A decoration view is meant to be added once. If it already has a superview, that is reported and it is removed first, dropping its existing constraints, then added again.
- Touches follow UIKit hit testing. A background sits behind the content, so it never blocks controls. An interactive overlay receives touches inside its bounds and blocks what is behind it; use `.isUserInteractionEnabled(false)` to let touches through. A decoration isn't clipped, but touches outside the decorated view's bounds don't reach it, as usual in UIKit.

### Spacer and layout priorities

`Spacer` is an empty view that takes the remaining length along the axis of the stack it is in. Layout priorities are set with two modifiers on any view that return the same view as `Self`.

```swift
public init(minLength: CGFloat = 0)   // Spacer

// UIView
func contentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self
func compressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self
```

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

- A spacer gives way before views with content: on the stack's axis its hugging priority is `.fittingSizeLevel`, so it absorbs the extra space and the other views keep their intrinsic size. It doesn't grow on the cross axis.
- Several spacers in one stack share the extra space equally.
- `minLength` is a required minimum. When the stack can't fit it, the other views shrink according to their compression resistance; lower one with `compressionResistancePriority` to choose which view gives way first. If the fixed sizes in a stack can't fit at all, the required constraints conflict and UIKit breaks one of them, as with any Auto Layout.
- On an unbounded axis, such as the scrolling axis of a scroll view, there is no remaining length, so a spacer is only `minLength` long.
- The axis is read when the spacer is added to a `UIStackView`, whether from a content closure or with `addArrangedSubview`. Changing that stack's `axis` afterwards isn't followed. A spacer outside a `UIStackView` has no effect, and adding it to one is reported.
- For a fixed gap, use `frame` on an empty view or the stack's `spacing`.
- These priorities are UIKit's content hugging and compression resistance, not SwiftUI's `layoutPriority`: they only decide between views that would otherwise be sized from their intrinsic content size.

### Scroll views

`HScroll` and `VScroll` are scrolling stacks: the elements you list are arranged by an embedded `HStack` or `VStack`, so there is no need to write a stack inside. Both are `UIScrollView` subclasses, so the delegate, `contentOffset` and every other native scroll view API stay available; the library never sets the delegate.

```swift
init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0, showsIndicators: Bool = true,
     @UIViewBuilder content: () -> [UIView])     // HScroll
init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0, showsIndicators: Bool = true,
     @UIViewBuilder content: () -> [UIView])     // VScroll
```

```swift
let tagRow = HScroll(spacing: 8, showsIndicators: false) {
    for name in tagNames { chip(name) }
}
.padding(.horizontal, 16)

view.addVScroll(alignment: .fill, spacing: 12) {
    title
    body
    tagRow
}
.padding(16)
```

- `alignment`, `spacing` and the content closure mean the same as for `HStack` and `VStack`, and take the same defaults. `addHScroll` and `addVScroll` take the same parameters plus `safeArea`, mount through `addContent`, and return the scroll view.
- The embedded stack's edges are pinned to the `contentLayoutGuide`, so the elements decide the scrollable length. On the other axis the stack is pinned to the `frameLayoutGuide`: a `VScroll`'s stack is as wide as the scroll view, an `HScroll`'s stack as tall, and `alignment` places the elements across it. When the scroll view resizes or an element changes, such as a label wrapping onto more lines, the content size follows.
- Content shorter than the scroll view keeps its own length and is not stretched to fill it. An empty `VScroll {}` has a content size of zero along the scrolling axis.
- The scrolling axis is unbounded, so a `Spacer` in a scroll view is only `minLength` long.
- A scroll view has no intrinsic size along its scrolling axis. Nested in a stack, an `HScroll` takes its height from its elements but needs its width from outside, and a `VScroll` the reverse: use `.fill` alignment in the enclosing stack, as above, or `frame`. With `.leading`, `.center` or `.trailing` it collapses to zero length.
- `showsIndicators` controls the indicator of the scrolling direction.
- `contentInsetAdjustmentBehavior` is `.never`, so the scroll view adds no automatic safe-area inset and its content starts at its edges. Mount it with `safeArea` to keep the whole scroll view inside the safe area, or use `.contentInsetAdjustmentBehavior(.automatic)` to let content scroll under bars while starting clear of them.
- Bouncing keeps UIKit's defaults: content shorter than the scroll view doesn't bounce unless you turn on `alwaysBounceVertical` or `alwaysBounceHorizontal`.

Modifiers return the same scroll view as `Self`:

| Type | Modifiers |
| --- | --- |
| `HScroll`, `VScroll` | `showsIndicators`, `alignment`, `spacing`, `padding(_ length:)`, `padding(_ edges:_ length:)` |
| `UIScrollView` | `bounces`, `alwaysBounceHorizontal`, `alwaysBounceVertical`, `contentInsetAdjustmentBehavior` |

`alignment`, `spacing` and `padding` configure the embedded stack. Padding lies inside the scrolled content, so it scrolls with the elements and counts toward the content size. For any other stack setting, such as `distribution`, the other `padding` forms or a stack `background`, use the read-only `stack` property:

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background { card } }
```

Keyboard avoidance and reusable lists are out of scope; use `UICollectionView` or `UITableView` for long, reusable content.

## Example app

`Example/Example.xcodeproj` is a small iOS app that uses the library as a local package. Open it in Xcode, choose the `Example` scheme and an iOS Simulator, and run. It has three screens:

- **Profile card** — stacks, `frame`, a card `background` and a status badge placed with `overlay`. The buttons change the bio label and the badge through references the view controller keeps, and the card resizes with them.
- **Form** — text fields, a text view that grows with its text, a switch and a slider, wired with UIKit's own delegates and target–action.
- **Scrolling** — `HScroll` rows inside a `VScroll`, and rows appended to a stack at runtime.

All text uses `font(textStyle:)`, so the screens follow Dynamic Type, and they adapt to rotation. Content closures run once; later changes are made through the views themselves, not through data binding.

Each screen mounts its scroll view with `safeArea: .all`, so content stays clear of the navigation bar, the home indicator and, in landscape, the sensor housing, while the screen's background color still fills the whole display.

The app's deployment target is iOS 15.0, the lowest the current Xcode can build; see [Known limitations](#known-limitations).

## Roadmap

Available today: the Swift package foundation, `addContent` mounting, `UIViewBuilder` with `HStack` and `VStack`, property modifiers for `UIView`, `UILabel`, `UIImageView`, `UIControl`, `UIButton`, `UISwitch`, `UISlider`, `UITextField` and `UITextView`, `padding` for stacks, `frame` size constraints, `background` and `overlay`, `Spacer` with layout priority modifiers, `HScroll` / `VScroll`, safe-area mounting, and an example app.

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
