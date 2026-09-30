# DeclarativeUIKit

[English](README.md) | **简体中文** | [繁體中文](README.zh-Hant.md)

一个轻量的 UIKit 声明式布局库，基于原生 `UIView` 与 Auto Layout 构建，不依赖任何第三方库。

它不引入自定义渲染层，也不维护平行的视图层级。你拿到的始终是真正的 `UIView` 或其子类，因此可以与现有 UIKit 代码自由混用。截图见[示例应用](#示例应用)。

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

## 环境要求

- iOS 13.0+
- Swift 5.9+
- 无外部依赖，仅使用系统 UIKit

## 安装

使用 Swift Package Manager。在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.1.0")
]
```

或在 Xcode 中选择 File → Add Package Dependencies，输入 `https://github.com/nothingsh/DeclarativeUIKit`。

## 用法

### `addContent(_:)`

把视图挂载到父视图中，使其填满父视图，或在你指定的边上填满父视图的安全区。

```swift
@discardableResult
func addContent<Content: UIView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(UILabel())   // 返回这个 UILabel，可以继续配置
view.addContent(customView)              // 返回值可以忽略
view.addContent(page, safeArea: .all)    // 保持在安全区内
```

- 默认把内容的四条边固定到父视图的四条边，使其填满父视图的 bounds，并忽略安全区。
- `safeArea` 中列出的边改为固定到父视图的 `safeAreaLayoutGuide`。在这些边上，内容（包括它绘制的背景）都保持在安全区内，并随安全区的变化（例如旋转）而调整。只列出部分边，其余的边就可以延伸到父视图边缘：`safeArea: .horizontal` 让内容在横屏时避开传感器区域，但仍延伸到状态栏下方。
- 使用 `leadingAnchor` 与 `trailingAnchor`，因此布局会在从右到左的语言中自动镜像。`LayoutEdges` 与 `padding` 使用的是同一个 option set。
- 返回传入的同一个实例，并保留其具体类型。
- 不改动内容自身的尺寸约束。

一个视图应当只挂载一次。若内容已有 superview 时再次调用，会通过 `NSLog` 打印一条提示，把内容从当前父视图移除（这会删掉它与旧层级之间的约束），然后重新挂载。约束不会累积，但内容会移到子视图顺序的最前面。

### Stack

`HStack` 与 `VStack` 沿一条轴排列视图。两者都是 `UIStackView` 的子类，所有原生 stack API 仍然可用。

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

- `alignment` 作用于交叉轴。`VStack` 接受 `HorizontalAlignment`：`leading`、`center`、`trailing`、`fill`。`HStack` 接受 `VerticalAlignment`：`top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline`、`fill`。基线对齐使用 UIKit 自身的基线对齐。`fill` 在 SwiftUI 中没有对应项，它会让每个元素在交叉轴上拉伸填满。
- `spacing` 默认为 `0`，与 `UIStackView` 一致，因此你看到的间距就是你写下的间距。这一点与 SwiftUI 不同，SwiftUI 的默认间距取决于上下文。
- `distribution` 使用 UIKit 自身的默认值 `.fill`，通过 modifier 而不是构造器参数来配置。
- 构造 stack 并不会把它挂载到任何地方，元素保持声明时的顺序。

一步完成构造与挂载：

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` 与 `addVStack` 接受与构造器相同的参数，外加 `safeArea`，通过 `addContent` 挂载新建的 stack 并将其返回。与 `addContent` 一样，除非你指定安全区的边，否则 stack 会填满父视图：

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

Stack 的 modifier 返回该 stack，因此可以在构造之后或挂载之后继续配置：

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` 与 `distribution(_:)` 适用于任何 `UIStackView`。`alignment(_:)` 按方向分别定义，在 `HStack` 上接受 `VerticalAlignment`，在 `VStack` 上接受 `HorizontalAlignment`。

### 内容闭包

Stack 的内容用 `@UIViewBuilder` 编写，它按声明顺序收集视图，并支持：

| 形式 | 示例 |
| --- | --- |
| 一个视图 | `UILabel()` |
| 可选视图 | `subtitle`，其中 `subtitle: UILabel?`，为 `nil` 时不产生任何元素 |
| 视图数组 | `rows`，其中 `rows: [UIView]` |
| `if` 以及 `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(iOS 14, *) { modernView }` |
| 什么都不写 | `VStack {}` |

不是 `UIView` 的表达式会导致编译失败，而不会被悄悄丢弃。

一个 `UIView` 只能属于一个父视图，因此同一个实例不能在同一个内容闭包中出现两次。这属于编程错误：它会带着说明信息触发 trap，而不是悄悄合并成一个元素。

### 属性 modifier

属性 modifier 设置接收者的某个 UIKit 属性，并以 `Self` 返回同一个实例，因此链式调用中具体类型得以保留，通用 modifier 之后仍可以继续使用特定类型的 modifier。同一属性被设置两次时，以最后一次为准。

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)
    .numberOfLines(0)
    .accessibilityIdentifier("title")

title.text("Updated")   // 之后的更新通过同一个引用进行
```

| 类型 | Modifier |
| --- | --- |
| `UIView` 及其任何子类 | `configure`、`alpha`、`isHidden`、`isUserInteractionEnabled`、`contentMode`、`tintColor`、`clipsToBounds`、`accessibilityLabel`、`accessibilityIdentifier` |
| `UILabel` | `text`、`attributedText`、`font`、`font(textStyle:)`、`textColor`、`numberOfLines`、`textAlignment`、`lineBreakMode` |
| `UIImageView` | `image`、`highlightedImage` |
| `UIControl` 及其任何子类 | `isEnabled`、`isSelected`、`isHighlighted` |
| `UIButton` | `title`、`titleColor`、`image`、`backgroundImage`，均带 `for state: UIControl.State = .normal` |
| `UISwitch` | `isOn`、`onTintColor` |
| `UISlider` | `value`、`minimumValue`、`maximumValue`、`minimumTrackTintColor`、`maximumTrackTintColor` |
| `UITextField` | `text`、`attributedText`、`placeholder`、`font`、`font(textStyle:)`、`textColor`、`textAlignment`、`keyboardType`、`returnKeyType`、`isSecureTextEntry` |
| `UITextView` | `text`、`attributedText`、`font`、`font(textStyle:)`、`textColor`、`textAlignment`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`isEditable`、`isSelectable`、`isScrollEnabled` |

每个 modifier 接受的类型与它所设置的 UIKit 属性相同。它们并不是 UIKit 的完整镜像；其他属性请使用 `configure`，它会以具体类型把视图交给你：

```swift
let avatar = UIImageView()
    .image(photo)
    .contentMode(.scaleAspectFill)
    .clipsToBounds(true)
    .configure { $0.layer.cornerRadius = 24 }
```

- `font(textStyle:)` 使用该文本样式对应的系统字体，并开启 `adjustsFontForContentSizeCategory`，因此 label 会跟随动态字体（Dynamic Type）。`font(_:)` 只设置字体，与 UIKit 属性完全一致。
- `numberOfLines(0)` 允许 label 换行；在 Auto Layout 下，它的高度随可用宽度变化。

按钮的 modifier 按控件状态分别设置值，通过 UIKit 的 `setTitle(_:for:)` 及同类方法实现，因此各个状态之间不会互相覆盖。没有单独设置值的状态会回退到 `.normal`，与 UIKit 一致。本库不使用 `UIButton.Configuration`。

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

- 事件使用 UIKit 自身的 target–action：`play.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)`。modifier 不会添加 target，也没有闭包形式的事件处理。
- 通过 `isOn` 或 `value` 设置值不属于用户事件，不会发送 `.valueChanged`，与 UIKit 属性一致。
- `UISlider` 会把 `value` 限制在当前范围内，因此请先设置 `minimumValue` 与 `maximumValue`，再设置 `value`。

文本输入的 modifier 以同样的方式配置 `UITextField` 与 `UITextView`；`font(textStyle:)` 与 label 一样跟随动态字体。

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

- `placeholder` 只存在于 `UITextField` 上，因为 UIKit 中的 `UITextView` 没有占位文字，本库也不会额外添加。
- 文本视图的尺寸取决于 `isScrollEnabled`。为 `false` 时，它在给定宽度下与文本一样高，并随文本增长而变高，就像多行 label。为 `true`（UIKit 的默认值）时，它没有固有高度：需要通过 `frame` 或约束给它一个高度，较长的文本会在其内部滚动。
- 代理、编辑行为与键盘仍然是 UIKit 自己的。modifier 不设置代理，也没有双向绑定、输入校验或键盘避让。

### Padding

Padding 是 stack 的 modifier。它设置 stack 的 `directionalLayoutMargins`，开启 `isLayoutMarginsRelativeArrangement` 并关闭 `insetsLayoutMarginsFromSafeArea`，然后返回同一个 stack。

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
stack.padding(horizontal: 16, vertical: 12)                   // 每条轴一个值
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // 每条边都不同
stack.padding(.top, 24, others: 8)                            // 单独一条边，其余相同
```

- Padding 计入 stack 的尺寸：内容为 20 × 30 的 stack，加上 `.padding(10)` 后为 40 × 50。
- 它的行为类似属性。`padding(_:_:)` 只改变你指定的边，其余的边保持不变，因此 `.padding(.horizontal, 16).padding(.vertical, 12)` 会设置全部四条边。其他形式都在一次调用中设置全部四条边。后一次调用会替换之前的值，而不是叠加。
- `LayoutEdges` 是由 `top`、`leading`、`bottom`、`trailing` 以及 `horizontal`、`vertical`、`all` 组成的 option set。水平方向的边是 `leading` 与 `trailing`，因此在从右到左的语言中会镜像。
- Padding 是固定留白，从不包含安全区。要让内容保持在安全区内，请用 `safeArea` 挂载；参见 [`addContent(_:)`](#addcontent_)。
- 要给单个视图加 padding，把它放进 stack：`VStack { label }.padding(16)`。

### Frame

`frame` 在视图自身上添加尺寸约束，并以 `Self` 返回它，因此链式调用保留具体类型。与 SwiftUI 一样，它有固定尺寸和尺寸范围两种形式。

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

- 它把 `translatesAutoresizingMaskIntoConstraints` 设为 `false`，并使用 required 优先级的 `widthAnchor` / `heightAnchor` 约束：固定长度用 `==`，最小值用 `>=`，最大值用 `<=`。
- 每次调用会重新定义它指定的轴，另一条轴保持不变。先调用 `frame(width: 100)` 再调用 `frame(width: 120)`，更新的是同一条约束。固定宽度会移除之前的最小或最大宽度，范围形式会移除之前的固定宽度，因此两者之间切换不会冲突。在范围形式中，某条轴只指定一个界限时会移除另一个：在 `frame(maxWidth: 200)` 之后调用 `frame(minWidth: 40)`，只保留最小值。
- 最大值可以传 `.infinity`，表示没有上限，不会添加约束。
- `frame(aspectRatio:)` 保持宽度等于该比例乘以高度，与 SwiftUI 一致（`16 / 9` 表示宽大于高）。把它与固定的宽度或高度搭配使用，可以推导出另一边的长度；若宽高也都固定，则会冲突。重复调用会替换比例，传 `nil` 则移除。
- 只会更新或移除 `frame` 自己创建的约束。你自己添加的尺寸约束永远不会被改动。
- 负数或非有限的固定长度或最小值、负数或 NaN 的最大值、最小值大于最大值，以及不是有限正数的宽高比，都属于编程错误，会带着说明信息触发 trap。

### Background 与 overlay

`background(_:)` 设置视图自身的 `backgroundColor`。视图形式的装饰会作为被装饰视图的子视图添加，并用约束固定。所有形式都以 `Self` 返回同一个视图。不会插入容器视图，也没有 `ZStack`。

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

- `background(_:)` 适用于任何视图，只设置 `backgroundColor`；它是本库中对应这个属性的 modifier。在 iOS 13 上 stack 不会绘制自己的 `backgroundColor`；如需支持 iOS 13，请改用 `background { ... }` 给 stack 放一个带颜色的视图。
- `background { ... }` 是 stack 的 modifier。该视图位于 stack 内容的后面，在默认的 `.fill` 下覆盖整个 stack（包括 padding）。要在单个视图后面放背景视图，把该视图放进 stack：`VStack { label }.padding(8).background { badgeShape }`。
- `overlay` 适用于任何视图，位于该视图现有子视图的前面，在默认的 `.fill` 下覆盖整个视图。之后添加的子视图（例如之后追加的 arranged subview）会位于它的前面。
- 被装饰视图的内容决定其尺寸。在 `.fill` 下，装饰视图的 hugging 与 compression resistance 被设为 `.fittingSizeLevel`，因此一张大图不会把视图撑大。但如果装饰视图自己的子视图要求最小尺寸（例如一组 label 组成的 stack），仍然可能撑大。
- `LayoutAlignment` 取值为 `fill`、`center`、`top`、`bottom`、`leading`、`trailing`、`topLeading`、`topTrailing`、`bottomLeading` 或 `bottomTrailing`。`fill` 把装饰拉伸覆盖整个视图。其他取值保留装饰自身的尺寸，并把它放在对应位置。`leading` 与 `trailing` 在从右到左的语言中会镜像。
- 视图装饰会叠加，与 SwiftUI 一致：后添加的 `background { ... }` 位于更后面，后添加的 `overlay` 位于更前面。
- 装饰视图应当只添加一次。若它已有 superview，会打印提示，先将其移除（同时删掉其已有约束），再重新添加。
- 触摸遵循 UIKit 的命中测试。背景位于内容后面，因此从不遮挡控件。可交互的 overlay 会接收其 bounds 内的触摸，并遮挡其后的内容；使用 `.isUserInteractionEnabled(false)` 让触摸穿透。装饰视图不会被裁剪，但落在被装饰视图 bounds 之外的触摸不会到达它，这与 UIKit 的一般行为相同。

### Spacer 与布局优先级

`Spacer` 是一个空视图，它沿所在 stack 的轴占据剩余长度。布局优先级通过两个 modifier 设置，适用于任何视图，并以 `Self` 返回同一个视图。

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

- Spacer 会先于有内容的视图让步：在 stack 的轴上，它的 hugging 优先级为 `.fittingSizeLevel`，因此它吸收多余的空间，其他视图保持固有尺寸。它在交叉轴上不会变大。
- 同一个 stack 中的多个 spacer 平分多余的空间。
- `minLength` 是 required 的最小值。当 stack 放不下时，其他视图按各自的 compression resistance 收缩；用 `compressionResistancePriority` 调低某个视图的优先级，可以决定哪个视图先让步。如果 stack 中的固定尺寸根本放不下，required 约束就会冲突，UIKit 会打破其中一条，这与任何 Auto Layout 布局一样。
- 在无界的轴上（例如滚动视图的滚动轴）没有剩余长度，因此 spacer 的长度只有 `minLength`。
- 轴是在 spacer 被添加到 `UIStackView` 时读取的，无论是通过内容闭包还是通过 `addArrangedSubview`。之后修改该 stack 的 `axis` 不会被跟随。不在 `UIStackView` 中的 spacer 不起作用，把它添加到非 stack 视图时会打印提示。
- 需要固定间隔时，请对空视图使用 `frame`，或使用 stack 的 `spacing`。
- 这些优先级是 UIKit 的 content hugging 与 compression resistance，而不是 SwiftUI 的 `layoutPriority`：它们只在原本会按固有内容尺寸决定大小的视图之间起作用。

### 滚动视图

`HScroll` 与 `VScroll` 是可滚动的 stack：你列出的元素由内置的 `HStack` 或 `VStack` 排列，因此不必在里面再写一个 stack。两者都是 `UIScrollView` 的子类，因此代理、`contentOffset` 以及所有原生滚动视图 API 仍然可用；本库从不设置代理。

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

- `alignment`、`spacing` 与内容闭包的含义和 `HStack`、`VStack` 相同，默认值也相同。`addHScroll` 与 `addVScroll` 接受相同的参数，外加 `safeArea`，通过 `addContent` 挂载并返回滚动视图。
- 内置 stack 的四边固定到 `contentLayoutGuide`，因此由元素决定可滚动的长度。在另一条轴上，stack 固定到 `frameLayoutGuide`：`VScroll` 的 stack 与滚动视图等宽，`HScroll` 的 stack 与滚动视图等高，`alignment` 决定元素在这条轴上的位置。当滚动视图尺寸变化或某个元素变化（例如 label 换行变成更多行）时，content size 会随之更新。
- 比滚动视图短的内容保持自身长度，不会被拉伸填满。空的 `VScroll {}` 在滚动轴上的 content size 为零。
- 滚动轴是无界的，因此滚动视图中的 `Spacer` 长度只有 `minLength`。
- 滚动视图在滚动轴上没有固有尺寸。嵌套在 stack 中时，`HScroll` 的高度由元素决定，但宽度需要由外部给出，`VScroll` 则相反：请像上面那样在外层 stack 中使用 `.fill` 对齐，或使用 `frame`。若使用 `.leading`、`.center` 或 `.trailing`，它的长度会塌缩为零。
- `showsIndicators` 控制滚动方向上的指示器。
- `contentInsetAdjustmentBehavior` 为 `.never`，因此滚动视图不会自动添加安全区 inset，内容从其边缘开始。用 `safeArea` 挂载可以让整个滚动视图保持在安全区内；或者使用 `.contentInsetAdjustmentBehavior(.automatic)`，让内容可以滚动到导航栏等栏的下方，同时起始位置避开它们。
- 回弹保持 UIKit 的默认行为：比滚动视图短的内容不会回弹，除非你开启 `alwaysBounceVertical` 或 `alwaysBounceHorizontal`。

Modifier 以 `Self` 返回同一个滚动视图：

| 类型 | Modifier |
| --- | --- |
| `HScroll`、`VScroll` | `showsIndicators`、`alignment`、`spacing`、`padding(_ length:)`、`padding(_ edges:_ length:)` |
| `UIScrollView` | `bounces`、`alwaysBounceHorizontal`、`alwaysBounceVertical`、`contentInsetAdjustmentBehavior` |

`alignment`、`spacing` 与 `padding` 配置的是内置 stack。Padding 位于滚动内容之内，因此会随元素一起滚动，并计入 content size。其他 stack 设置，例如 `distribution`、其他形式的 `padding` 或 stack 的 `background`，请使用只读的 `stack` 属性：

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background { card } }
```

键盘避让与可复用列表不在本库范围内；长的、需要复用的内容请使用 `UICollectionView` 或 `UITableView`。

## 示例应用

`Example/Example.xcodeproj` 是一个以本地 package 方式使用本库的小型 iOS 应用。在 Xcode 中打开它，选择 `Example` scheme 和一个 iOS 模拟器，然后运行。下面的代码片段节选自它的三个页面。

### 个人资料卡片

代码的结构与界面的结构一致。状态徽标通过 `overlay` 附加到头像上，不需要包装视图，也不需要 `ZStack`。`bio` 和 `status` 都是普通属性：按钮直接修改它们，Auto Layout 会调整卡片的大小。不会重建任何视图。

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

// 之后，在按钮的 action 中：
bio.text(Self.longBio)
status.background(.systemGray)
```

</td>
<td width="300">
<img src="docs/images/example-profile.png" width="300" alt="个人资料卡片页面">
</td>
</tr>
</table>

可复用的样式只是一个基于 modifier 的函数。`card()` 是示例应用自己的辅助方法，不属于本库：

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

### 表单

控件就是普通的 `UITextField`、`UISwitch` 和 `UISlider`，用 modifier 配置并作为属性持有。事件使用 UIKit 自身的 target–action 与代理。`Spacer` 把开关和数值推到尾部边缘。

<table>
<tr>
<td>

```swift
private let newsletter = UISwitch().isOn(true)

private let frequency = UISlider()
    .minimumValue(1)
    .maximumValue(7)
    .value(3)

// 在 viewDidLoad 中：
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
<img src="docs/images/example-form.png" width="300" alt="表单页面">
</td>
</tr>
</table>

### 滚动

`VScroll` 中嵌套 `HScroll` 行。内容闭包支持 `for` 循环，返回 `UIView` 的小函数可以像其他视图一样组合。点击 *Add row* 会向作为属性持有的 stack 追加一行，滚动视图的 content size 随之更新。

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
<img src="docs/images/example-scroll.png" width="300" alt="滚动页面">
</td>
</tr>
</table>

所有文字都使用 `font(textStyle:)`，因此各页面会跟随动态字体，并能适应旋转。内容闭包只运行一次；之后的变化通过视图本身完成，而不是通过数据绑定。

每个页面都用 `safeArea: .all` 挂载其滚动视图，因此内容会避开导航栏、主屏幕指示条以及横屏时的传感器区域，而页面的背景色仍然铺满整个屏幕。

示例应用的部署目标是 iOS 15.0，这是当前 Xcode 能构建的最低版本；参见[已知限制](#已知限制)。

## 路线图

目前已提供：Swift package 基础、`addContent` 挂载、`UIViewBuilder` 与 `HStack`、`VStack`，`UIView`、`UILabel`、`UIImageView`、`UIControl`、`UIButton`、`UISwitch`、`UISlider`、`UITextField` 与 `UITextView` 的属性 modifier，stack 的 `padding`，`frame` 尺寸约束，`background` 与 `overlay`，`Spacer` 与布局优先级 modifier，`HScroll` / `VScroll`，安全区挂载，以及一个示例应用。

1.0 之前 API 可能会发生变化。

## 已知限制

本 package 声明的最低版本是 iOS 13，新 API 都按 iOS 13 的可用性审查过，但从未针对 iOS 13 本身构建或运行过，因为当前的工具链已不再支持这个部署目标。目前经过验证的，是在较新 iOS 版本上的编译与测试。

## 开发

测试会调用 UIKit，必须在 iOS 模拟器中运行。在 macOS 上执行 `swift test` 不是本库有效的测试方式。

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

使用 `xcrun simctl list devices available` 查找 UDID。未设置 `IOS_SIMULATOR_ID` 时，脚本会列出已安装的设备并退出。它会转发额外的 `xcodebuild` 参数，并把日志和测试结果写入 `.build/validation/`。

## 许可证

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
