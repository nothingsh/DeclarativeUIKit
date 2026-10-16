<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/declarative-uikit-dark.svg">
    <img src="docs/images/declarative-uikit-light.svg" alt="DeclarativeUIKit — 基于原生 UIView 的 UIKit 声明式布局。" width="850">
  </picture>
</p>

# DeclarativeUIKit

[English](README.md) | **简体中文** | [繁體中文](README.zh-Hant.md)

一个轻量的 UIKit 声明式布局库，基于原生 `UIView` 与 Auto Layout 构建，不依赖任何第三方库。

它不引入自定义渲染层，也不维护平行的视图层级。你拿到的始终是真正的 `UIView` 或其子类，因此可以与现有 UIKit 代码自由混用。截图见[示例应用](#示例应用)。

数据绑定由配套的包 [DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine) 提供，见[数据绑定](#数据绑定)。

AppKit 版本见兄弟包 [DeclarativeAppKit](https://github.com/nothingsh/DeclarativeAppKit)。

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

## 目录

- [安装](#安装)
- [用法](#用法)
  - [挂载](#挂载)
  - [Stack](#stack)
  - [属性 modifier](#属性-modifier)
  - [事件](#事件)
  - [Padding 与 frame](#padding-与-frame)
  - [Background 与 overlay](#background-与-overlay)
  - [Spacer](#spacer)
  - [滚动视图](#滚动视图)
  - [键盘](#键盘)
  - [列表](#列表)
  - [Xcode 预览](#xcode-预览)
  - [调试布局](#调试布局)
- [数据绑定](#数据绑定)
- [示例应用](#示例应用)
  - [个人资料卡片](#个人资料卡片)
  - [表单](#表单)
  - [滚动](#滚动)
  - [分组列表](#分组列表)
- [已知限制](#已知限制)
- [开发](#开发)
- [许可证](#许可证)

## 安装

需要 iOS 15.0+ 与 Swift 5.9+。使用 Swift Package Manager 添加：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.9.0")
]
```

或在 Xcode 中选择 File → Add Package Dependencies，输入 `https://github.com/nothingsh/DeclarativeUIKit`。

各版本的变更见 [CHANGELOG.md](CHANGELOG.md)。版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。从 1.0 起，次版本只新增 API；改名的 API 会以已废弃的形式保留到下一个主版本；最低 iOS 版本只在主版本提高。1.0 之前，次版本可能修改 API，变更日志会给出迁移方法。API 参考文档：在 Xcode 中打开本 package，选择 Product → Build Documentation；其中还有一篇编写可复用组件的指南。

## 用法

### 挂载

```swift
view.addContent(page)                          // 填满父视图
view.addContent(page, safeArea: .all)          // 保持在安全区内

view.addVStack(spacing: 8, safeArea: .top) {   // 构造 stack 并挂载
    title
    body
}
```

`addContent` 把视图的四条边固定到父视图，并返回带有具体类型的该视图。`safeArea` 中列出的边改为固定到父视图的安全区。`addHStack`、`addVStack`、`addHScroll` 与 `addVScroll` 把构造和挂载合成一步。

### Stack

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

- `HStack` 与 `VStack` 是 `UIStackView` 的子类，所有原生 stack API 仍然可用。构造 stack 不会挂载它。
- `alignment` 是交叉轴上的对齐：`VStack` 可取 `leading`、`center`、`trailing` 或 `fill`；`HStack` 可取 `top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline` 或 `fill`。`fill` 会拉伸每个元素。
- `spacing` 默认为 `0`，因此你看到的间距就是你写下的间距。之后可以用 `.spacing(_:)`、`.alignment(_:)` 与 `.distribution(_:)` 修改，用 `.spacing(_:after:)` 单独设置某个元素之后的间距。
- 内容闭包接受视图、可选视图、数组、`if` / `else`、`switch`、`for` 与 `if #available`。
- 内容闭包只运行一次。之后要显示别的元素，持有这个 stack 并调用 `replaceContent { … }`：旧元素会移出视图层级，background 与 overlay 保留。

### 属性 modifier

每个 modifier 设置一个 UIKit 属性，并以 `Self` 返回该视图，因此链式调用保留具体类型。

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)                   // 跟随 Dynamic Type
    .numberOfLines(0)

let body = UILabel()
    .font(UIFont(name: "Avenir-Book", size: 16)!, relativeTo: .body)  // 自定义字体，跟随 Dynamic Type
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
    .titleFont(textStyle: .headline)            // 跟随 Dynamic Type

let avatar = UIImageView()
    .image(photo)
    .cornerRadius(24)
    .clipsToBounds(true)
    .configure { $0.layer.zPosition = 1 }       // 没有对应 modifier 的属性
```

| 类型 | Modifier |
| --- | --- |
| `UIView` 及其任何子类 | `configure`、`alpha`、`isHidden`、`isUserInteractionEnabled`、`contentMode`、`tintColor`、`clipsToBounds`、`accessibilityLabel`、`accessibilityHint`、`accessibilityTraits`、`isAccessibilityElement`、`accessibilityIdentifier`、`cornerRadius`、`cornerRadius(_:corners:)`、`border(color:width:)`、`shadow`、`accessibilityCombined` |
| `UILabel` | `text`、`attributedText`、`font`、`font(textStyle:)`、`font(_:relativeTo:)`、`lineHeight`、`kerning`、`textColor`、`numberOfLines`、`textAlignment`、`lineBreakMode`、`adjustsFontSizeToFitWidth`、`minimumScaleFactor` |
| `UIImageView` | `image`、`highlightedImage`、`preferredSymbolConfiguration` |
| `UIControl` 及其任何子类 | `isEnabled`、`isSelected`、`isHighlighted` |
| `UIButton` | `title`、`titleColor`、`image`、`backgroundImage`，均带 `for state: UIControl.State = .normal` |
| 有 configuration 的 `UIButton` | `buttonSize`、`cornerStyle`、`contentInsets`、`baseForegroundColor`、`baseBackgroundColor`、`subtitle`、`titleAlignment`、`titlePadding`、`titleFont`、`titleFont(_:relativeTo:)`、`titleFont(textStyle:)`、`imagePlacement`、`imagePadding`、`preferredSymbolConfigurationForImage`、`showsActivityIndicator` |
| `UISwitch` | `isOn`、`onTintColor` |
| `UISlider` | `value`、`minimumValue`、`maximumValue`、`minimumTrackTintColor`、`maximumTrackTintColor` |
| `UIStepper` | `value`、`minimumValue`、`maximumValue`、`stepValue` |
| `UISegmentedControl` | `selectedSegmentIndex`、`selectedSegmentTintColor`、`isMomentary` |
| `UIPageControl` | `numberOfPages`、`currentPage`、`hidesForSinglePage`、`pageIndicatorTintColor`、`currentPageIndicatorTintColor` |
| `UIProgressView` | `progress(_:animated:)`、`progressTintColor`、`trackTintColor` |
| `UIActivityIndicatorView` | `isAnimating`、`hidesWhenStopped`、`color` |
| `UITextField` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`font(textStyle:)`、`font(_:relativeTo:)`、`textColor`、`textAlignment`、`borderStyle`、`clearButtonMode`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType` |
| `UITextView` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`font(textStyle:)`、`font(_:relativeTo:)`、`textColor`、`textAlignment`、`textContainerInset`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType`、`isEditable`、`isSelectable`、`isScrollEnabled` |

`font(textStyle:)` 跟随 Dynamic Type，`font(_:)` 则设置固定字体。`font(_:relativeTo:)` 让自定义字体像该文字样式的系统字体一样跟随 Dynamic Type；传入默认文字大小下应有的字号。按钮的 modifier 为每个控件状态各设置一个值。`value`、`selectedSegmentIndex`、`currentPage` 这类设置值的 modifier 不会发送 `.valueChanged`。

有 configuration 的按钮的 modifier 修改它的 `UIButton.Configuration`，所以要用 `UIButton(configuration:)` 创建按钮；对没有 configuration 的按钮调用时会以 precondition 失败终止。`title` 和 `image` 对两种按钮都有效，并且按状态生效。有 configuration 的按钮请用 `baseForegroundColor` 而不是 `titleColor` 设置文字颜色，用 configuration 的 `background` 而不是 `backgroundImage` 设置背景。`titleFont` 会替换 configuration 的 `titleTextAttributesTransformer`；`relativeTo:` 与 `textStyle:` 两种形式跟随 Dynamic Type。

`lineHeight` 设置每行的高度，与设计工具中的行高相同；`kerning` 设置每个字符后的间距。`UILabel` 没有对应的属性，所以由 label 保存这两个值并写入 `attributedText`。`text`、`attributedText`、`font` modifier 会重新应用它们；直接赋值 `label.text = …` 不会，所以更新文字时请用 `label.text(…)`。文字按 UIKit 的方式贴在每行底部，而不像设计工具那样垂直居中。行高相对于字体，所以会随 Dynamic Type 变大。

`UITextView` 本身没有 placeholder。`placeholder` 和 `attributedPlaceholder` 在文本视图为空时，在文字开始的位置显示一行占位文字，颜色默认为占位符颜色，带属性的形式则按它自己的属性。输入时它会自动隐藏和显示；`text`、`attributedText`、`font`、`textAlignment`、`textContainerInset` modifier 会同步更新它，直接赋值 `textView.text = …` 不会。

`cornerRadius`、`border` 与 `shadow` 设置视图的 layer。`cornerRadius` 不会裁剪：需要时加上 `clipsToBounds(true)`，但它也会裁掉阴影。`corners` 只圆指定的角，按物理方向命名，例如左上角 `.layerMinXMinYCorner`，因此不会随从右到左的语言镜像。边框与阴影颜色会随浅色、深色模式切换：视图会多一个隐藏的子视图，在外观变化时重新解析颜色。直接给 `layer.borderColor` 赋值则不会跟随。

`accessibilityCombined()` 让 VoiceOver 把一个视图及其子视图读成一个元素，标签由可见子视图的标签依次连接而成，并随它们变化。只合并标签，所以不要用在含有按钮等控件的区域。

### 事件

`onEvent` 在控件每次发送指定的 `UIControl.Event` 时运行闭包。闭包收到的是控件本身，类型不变，因此不用把控件存成属性，也能读取 `isOn`、`value` 或 `text`。`onTapGesture` 与 `onLongPressGesture` 适用于任何视图。

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

- 两个手势 modifier 各添加一个手势识别器，并打开 `isUserInteractionEnabled`；`UILabel` 和 `UIImageView` 默认是关闭的。`onTapGesture(count:perform:)` 默认点击一次。`onLongPressGesture(minimumDuration:perform:)` 在按压持续 `minimumDuration`（默认 0.5 秒）时运行一次闭包。
- 每次调用都会再添加一个 action 或识别器，之前的仍然保留。要停止响应，用 `isEnabled` 或 `isUserInteractionEnabled` 关闭控件或视图。
- 控件持有它的闭包，视图持有它的识别器及其闭包。捕获 view controller 时写 `[weak self]`，否则它与视图会互相持有。
- 代理（例如 `UITextFieldDelegate`）照常设置。

### Padding 与 frame

```swift
let card = VStack(alignment: .leading, spacing: 4) {
    name
    role
}
.padding(16)                // 每条边
.padding(.horizontal, 24)   // 只改指定的边

stack.padding(horizontal: 16, vertical: 12)
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)

let avatar = UIImageView().frame(width: 48, height: 48)
let button = UIButton().frame(minWidth: 88)
let banner = UIImageView().frame(width: 320).frame(aspectRatio: 16 / 9)   // 320 × 180
```

- `padding` 是 stack 的 modifier。它在每条边上都是固定距离，计入 stack 的尺寸，从不包含安全区。要给单个视图加 padding，把它放进 stack。
- `frame` 给任意视图添加 required 的尺寸约束。对同一条轴的后一次调用会替换前一次。

### Background 与 overlay

```swift
let badge = UILabel().text("New").background(.systemYellow)          // 视图自身的背景色

let card = VStack { name }
    .padding(16)
    .background { UIView().background(.secondarySystemBackground) }  // stack 后面的任意视图

// 在视图前面，并从角上向外偏移
let avatar = UIImageView()
    .frame(width: 48, height: 48)
    .overlay(alignment: .bottomTrailing, offset: CGPoint(x: 4, y: 4)) { statusDot }
```

- `background(_:)` 设置视图自身的 `backgroundColor`，stack 也会绘制它。`background { ... }` 则是在 stack 后面放一个完整的视图。
- `GradientView([.systemTeal, .systemBlue])` 绘制线性渐变，默认从上到下；配合 `background { … }` 使用。点使用单位坐标，与 `CAGradientLayer` 相同，颜色随深色模式变化。
- 视图形式的装饰是用约束固定的子视图；不会插入容器视图，也没有 `ZStack`。`alignment` 默认为 `.fill`，也可以是 `.topTrailing` 这样的位置。
- 被装饰视图自身的内容决定其尺寸。
- `offset` 把装饰从 `alignment` 确定的位置移开：x 正值朝右，y 正值朝下。这个值原样交给 Auto Layout：在从右到左的布局中，leading 或 trailing 对齐的水平方向会反过来，居中的对齐则不会；如果不希望这样，请自行调整传入的值。`.fill` 不接受 offset。

### Spacer

```swift
let header = HStack {
    title.compressionResistancePriority(.defaultLow, for: .horizontal)
    Spacer(minLength: 8)
    badge
}
```

`Spacer` 沿所在 stack 的轴占据剩余长度，多个 spacer 平分它。`contentHuggingPriority(_:for:)` 与 `compressionResistancePriority(_:for:)` 决定其他视图中哪一个先变大或先收缩。

`Divider()` 是横穿所在 stack 的细线：在 `VStack` 中为横线，在 `HStack` 中为竖线。无论对齐方式如何，它都在 padding 之内铺满 stack，颜色为 `.separator`，可用 `background(_:)` 修改。

```swift
VStack(alignment: .leading, spacing: 12) {
    header
    Divider()
    body
}
.padding(16)
```

### 滚动视图

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

- `HScroll` 与 `VScroll` 是 `UIScrollView` 的子类，用内置的 stack 排列元素，可通过 `stack` 访问。元素决定 content size；在另一条轴上，内容与滚动视图一致。
- 嵌套在 stack 中时，`HScroll` 的高度由元素决定，但宽度需要由外部给出，`VScroll` 则相反：像上面那样使用 `.fill` 对齐，或使用 `frame`。
- `alignment`、`spacing`、`spacing(_:after:)`、`replaceContent` 以及各种形式的 `padding` 都会转发给 `stack`；padding 位于滚动内容之内。
- `contentInsetAdjustmentBehavior` 为 `.never`，因此内容从滚动视图的边缘开始。用 `safeArea` 挂载滚动视图可以让它保持在安全区内。
- `isPagingEnabled` 和 `keyboardDismissMode` 设置对应的属性。`onRefresh { await … }` 添加下拉刷新：刷新控件一直转动，直到闭包返回。再次调用会替换之前的操作。
- 内容较短时保持自身长度，因此沿滚动方向的 `Spacer` 没有空间可占。`fillsViewport(true)` 让内容至少与 `VScroll` 一样高，或与 `HScroll` 一样宽；多出的长度由 `Spacer` 占据，可以把按钮留在短表单的底部，内容更长时照常滚动：

```swift
view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    form
    Spacer()
    submit
}
.fillsViewport(true)
```

- 要让内容滚到半透明导航栏下面，只在左右两边把滚动视图约束到安全区，由 UIKit 按导航栏等设置内容的 inset。内容从导航栏下方开始，滚到导航栏下面时导航栏会显示背景。`fillsViewport` 与 `avoidsKeyboard` 会考虑这些 inset：

```swift
view.addVScroll(alignment: .fill, spacing: 12, safeArea: .horizontal) {
    form
}
.contentInsetAdjustmentBehavior(.automatic)
```

### 键盘

```swift
let email = UITextField()
    .placeholder("Email")
    .textContentType(.emailAddress)
    .returnKeyType(.next)
    .onEvent(.editingDidEndOnExit) { _ in password.becomeFirstResponder() }  // 按 return 跳到下一个输入框

view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    email
    password
    notes
}
.avoidsKeyboard(true)
```

- `avoidsKeyboard(true)` 适用于任何 `UIScrollView`，包括 `VScroll`、`VList` 和可滚动的 `UITextView`。键盘遮住滚动视图的一部分时，被遮住的高度会加到底部的 content inset 和滚动指示器 inset 上，正在编辑的输入框会滚到键盘上方。你自己设置的 inset 会保留。默认关闭。
- 只计算被遮住的部分：底边在键盘上方的滚动视图不变，iPad 上的浮动键盘不算遮挡。
- 滚动视图之外的视图不会移动。必须能点到的按钮请放在滚动视图内容的末尾。
- 按下 return 时文本框会发送 `.editingDidEndOnExit`，所以用 `onEvent` 就能跳到下一个输入框，不需要代理。

### 列表

`VList` 是竖直列表：行在滚动进入屏幕时才创建，数据更新时按差异刷新。它是使用 UIKit 列表布局和 diffable data source 的 `UICollectionView`，库只增加了行的声明方式。

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

- `update` 按 `id` 插入、删除、移动行，默认带动画。新旧数据中都有的 id 对应的行都会重新配置，所以 `Item` 不需要遵循 `Equatable`。id 在整个列表内必须唯一。
- `ListRow(OrderRow.self) { … }` 是可复用行。列表用 `init()` 创建 view，每个 cell 一次；每当这一行显示或其 item 变化时调用闭包，闭包里只做赋值。view 创建时拿不到 item，所以不会有某一项的数据残留在被复用到其他项的 view 上。
- `ListRow { … }` 每次都重建 view，适合静态的行，例如 App 版本号。带控件或频繁更新的行应当用可复用行，因为重建会丢失控件状态。
- `accessories` 接受 UIKit 的 `UICellAccessory`。只有设置了 `onSelect` 的行会高亮；闭包执行后该行立即取消选中。
- 行内容贴满 cell，由 Auto Layout 决定高度。列表本身不加内边距，padding 由每一行自己设置。
- 分组页面传入 `sections:` 和 `appearance`，例如 `.insetGrouped`。`ListSection` 接受 `id` 以及可选的 `header`、`footer` 文字，使用 UIKit 的默认样式。

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

- `listConfiguration` 调整每个 section 的 `UICollectionLayoutListConfiguration`。分割线的起点由系统决定，随 iOS 版本和机型变化；要和行的 padding 对齐，在这里设置 `separatorConfiguration`。
- 与滚动视图一样，`VList` 的 `contentInsetAdjustmentBehavior` 为 `.never`；用 `safeArea` 挂载它。
- 列表自己担任 `delegate` 来处理选中。替换 delegate 会让 `onSelect` 失效。
- 列表持有 row 闭包，每个 cell 持有自己的 `onSelect` 闭包。捕获 view controller 时写 `[weak self]`，否则它与列表会互相持有。
- 配合 [DeclarativeCombine](#数据绑定) 时，用 `onReceive` 把 publisher 接到 `update`：`list.onReceive(viewModel.$orders) { $0.update($1) }`。

标准样式的行、侧滑操作、加载更多和空状态：

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

- `ListRow(text:secondaryText:image:)` 是 UIKit 标准样式的行，由 cell 按列表外观的默认 content configuration 排版，分割线与文字对齐。`ListRow(content:)` 接受任意 `UIListContentConfiguration`，例如两侧都有文字的 `.valueCell()`。
- `leadingSwipeActions` 和 `trailingSwipeActions` 接受 UIKit 的 `UIContextualAction`，每个 handler 都必须调用它的 completion handler。`allowsFullSwipe` 默认开启，完整滑动会执行第一个操作。`listConfiguration` 不能修改侧滑操作。
- `onReachEnd` 在最后一行即将显示时运行。更新后出现的新最后一行、以及滚回视野的最后一行都会触发，所以正在加载时请忽略这些调用。
- `scrollTo` 按 id 滚动到某一行，默认只滚到刚好可见，也可以传入 `.top` 等位置。id 必须在列表中。
- `emptyView` 在列表没有任何行时显示在列表中央，即使有 section 标题也是如此。`offset` 让它偏离中央，x 向右为正、y 向下为正，与 `overlay` 相同。它保存在 `backgroundView` 中。
- `onRefresh` 适用于任何滚动视图，见[滚动视图](#滚动视图)。

### Xcode 预览

Xcode 15 及以上版本可以直接预览 UIKit 视图。UIKit 的 `#Preview` 宏需要 iOS 17，因此在支持更低版本的 target 中，要给预览加上 `@available(iOS 17, *)`。只有预览需要 iOS 17，其余代码的部署目标不变。

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

### 调试布局

库创建的每一条约束都以 `DeclarativeUIKit.` 加上创建它的 modifier 命名，例如 `addContent.top`、`frame.width`、`overlay.centerY`、`spacer.minLength` 或 `fillsViewport`。约束冲突时，控制台会显示这些名字，由此可以知道该修改哪个 modifier：

```text
Unable to simultaneously satisfy constraints.
    <NSLayoutConstraint:0x600002b0c3c0 'DeclarativeUIKit.frame.width' UIView:0x10310a2c0.width == 40   (active)>
    <NSLayoutConstraint:0x600002b0c460 'DeclarativeUIKit.addContent.leading' H:|-(0)-[UIView:0x10310a2c0]   (active, names: '|':UIView:0x10310a100 )>
```

UIKit 自己的工具照常可用：Xcode 的 View Debugger 显示视图层级和每个视图的约束，`hasAmbiguousLayout` 与 `exerciseAmbiguityInLayout()` 可以找出尺寸或位置没有完全确定的视图。

## 数据绑定

DeclarativeUIKit 只负责布局：内容闭包只运行一次，库本身不提供绑定。之后需要变化的视图，必须存成属性，再手动更新。

[DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine) 是配套的包，用来省掉这一步。它为 UIKit 的控件、滚动视图和手势提供 Combine publisher，并提供一组 modifier，让视图在声明它的地方直接绑定到 publisher：

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

它是可选的、独立的包。DeclarativeUIKit 不依赖它，它也不依赖 DeclarativeUIKit；两个包一起添加即可配合使用。它的示例应用把下面的[表单](#表单)页面重写了一遍，一个视图都没有存成属性。

## 示例应用

`Example/Example.xcodeproj` 是一个以本地 package 方式使用本库的小型 iOS 应用。在 Xcode 中打开它，选择 `Example` scheme 和一个 iOS 模拟器，然后运行。下面的代码片段节选自它的四个页面。

### 个人资料卡片

代码的结构与界面的结构一致。状态徽标通过 `overlay` 附加到头像上，不需要包装视图，也不需要 `ZStack`。`bio` 和 `status` 都是普通属性：按钮直接修改它们，Auto Layout 会调整卡片的大小。不会重建任何视图。`Divider` 分隔头部与简介，`accessibilityCombined` 让 VoiceOver 把姓名和职业读成一个元素。

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
                    .cornerRadius(12)
            }
    }
}
```

### 表单

控件就是普通的 `UITextField`、`UISwitch` 和 `UISlider`，用 modifier 配置并作为属性持有。事件用 `onEvent` 闭包处理，return 键跳到下一个输入框。页面用 `avoidsKeyboard` 为键盘留出空间，备注视图显示 placeholder。`Spacer` 把开关和数值推到尾部边缘。

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
            .cornerRadius(8)
    }
}
```

</td>
<td width="300">
<img src="docs/images/example-scroll.png" width="300" alt="滚动页面">
</td>
</tr>
</table>

### 分组列表

带标题和脚注的 `.insetGrouped` `VList`。`MessageRow` 和 `SwitchRow` 是可复用行；存储空间一行是标准行，版本号一行每次重建。点 *Add*、点击消息、侧滑删除和下拉刷新都会修改数据并调用 `update`：新行带动画插入，变化的行和标题里的未读数随之刷新。

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
    list.update(sections: sections())
}
```

</td>
<td width="300">
<img src="docs/images/example-list.png" width="300" alt="列表页面">
</td>
</tr>
</table>

所有文字都使用 `font(textStyle:)`，因此各页面会跟随动态字体，并能适应旋转。内容闭包只运行一次；之后的变化通过视图本身完成，而不是通过数据绑定。

每个页面只在左右两边把滚动视图约束到安全区，由 UIKit 按导航栏和主屏幕指示条设置内容的 inset。内容从导航栏下方开始并能滚到它下面，横屏时避开传感器区域，页面的背景色仍然铺满整个屏幕。

示例应用的部署目标是 iOS 15.0，与本 package 相同。

## 已知限制

`VScroll` 与 `HScroll` 不是惰性的：所有元素都会预先创建并布局。它们适合页面和较短的列表；较长或由数据驱动的列表请使用 [`VList`](#列表)。

## 开发

测试会调用 UIKit，必须在 iOS 模拟器中运行；在 macOS 上执行 `swift test` 不是有效的测试方式。

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

使用 `xcrun simctl list devices available` 查找 UDID。

## 许可证

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
