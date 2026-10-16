<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/declarative-uikit-dark.svg">
    <img src="docs/images/declarative-uikit-light.svg" alt="DeclarativeUIKit — Declarative layout for UIKit, on plain UIView." width="850">
  </picture>
</p>

# DeclarativeUIKit

[English](README.md) | **简体中文** | [繁體中文](README.zh-Hant.md)

像写 SwiftUI 一样写 UIKit 布局，得到的仍是普通的 `UIView`。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/hero-card-dark.png">
    <img src="docs/images/hero-card.png" width="420" alt="一张个人资料卡片：头像、姓名、职业、分隔线和一段简介">
  </picture>
</p>

```swift
view.addVScroll(alignment: .fill, spacing: 16, safeArea: .all) {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 12) {
            UIImageView(image: avatar)
                .frame(width: 64, height: 64)
                .overlay(alignment: .bottomTrailing) { statusDot }
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
        Divider()
        bio
    }
    .padding(16)
    .background { UIView().background(.secondarySystemGroupedBackground).cornerRadius(12) }
}
.padding(16)
```

## 为什么用 DeclarativeUIKit

- **它仍然是 UIKit。** `VStack` 就是 `UIStackView`，`VScroll` 就是 `UIScrollView`，每个 modifier 都返回调用它的那个视图。可以和已有代码、view controller、第三方视图随意混用。
- **代码的样子就是界面的样子。** 代码里怎么嵌套，屏幕上就怎么嵌套；Auto Layout 约束由库替你写。
- **所见即所得。** 不设置 spacing 就是 0，不加 padding 就没有留白，只有你指定的边才受安全区约束。

它很小，没有任何依赖，支持 iOS 15 及以上。

## 安装

使用 Swift Package Manager 添加：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.9.0")
]
```

或在 Xcode 中选择 File → Add Package Dependencies，输入 `https://github.com/nothingsh/DeclarativeUIKit`。需要 iOS 15.0+ 与 Swift 5.9+。

## 快速上手

```swift
import DeclarativeUIKit
import UIKit

final class ProfileViewController: UIViewController {
    private let bio = UILabel().font(textStyle: .body).numberOfLines(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.background(.systemBackground)

        view.addVStack(alignment: .fill, spacing: 12, safeArea: .all) {
            UILabel().text("Ada Lovelace").font(textStyle: .title2)
            bio
            UIButton(configuration: .filled())
                .title("Show more")
                .onEvent(.primaryActionTriggered) { [weak self] _ in
                    self?.bio.text("Wrote what is often called the first published program.")
                }
            Spacer()
        }
        .padding(16)
    }
}
```

一开始就要知道的两件事：

- **内容闭包只运行一次。** 它负责创建视图，不会重新渲染。之后要修改，就把视图存成属性（如上面的 `bio`）再修改它，或者用 [DeclarativeCombine](#数据绑定) 绑定。
- **没有 modifier 的属性也能设置。** `configure { $0.layer.zPosition = 1 }` 可以在链式调用中运行任意 UIKit 代码。

## 指南

### Stack

```swift
VStack(alignment: .leading, spacing: 8) {
    title
    if let subtitle { subtitle }
    for tag in tags { chip(tag) }
    HStack(spacing: 8) {
        icon
        Spacer()          // 占据剩下的空间
        badge
    }
    Divider()             // 横穿 stack 的细线
    footer
}
```

- `alignment` 决定元素在交叉方向上怎么对齐：`VStack` 用 `leading`、`center`、`trailing` 或 `fill`；`HStack` 用 `top`、`center`、`bottom`、文字基线或 `fill`。`spacing` 默认为 0。
- 内容闭包可以写视图、可选值、数组、`if`、`switch`、`for` 和 `if #available`。之后要换掉元素，对 stack 调用 `replaceContent { … }`。
- 之后要修改 stack，用 `.spacing(_:)`、`.spacing(_:after:)`、`.alignment(_:)` 和 `.distribution(_:)`。

### 尺寸与 padding

```swift
VStack { name; role }
    .padding(16)                          // 四条边
    .padding(.horizontal, 24)             // 只改这些边

UIImageView().frame(width: 48, height: 48)
UIButton().frame(minWidth: 88)
UIImageView().frame(width: 320).frame(aspectRatio: 16 / 9)

title.compressionResistancePriority(.defaultLow, for: .horizontal)
```

- `padding` 是 stack 的 modifier。要给单个视图加 padding，就把它放进一个 stack。
- `frame` 添加尺寸约束；对同一个方向再次调用会替换之前的约束。

### 把视图放到屏幕上

```swift
view.addContent(page)                          // 铺满父视图
view.addContent(page, safeArea: .all)          // 留在安全区内
view.addVStack(spacing: 8, safeArea: .top) {   // 创建 stack 并添加
    title
    body
}
```

`addContent`、`addHStack`、`addVStack`、`addHScroll` 和 `addVScroll` 把视图的四条边固定到父视图。`safeArea` 中列出的边改为停在安全区边缘，所以背景仍然可以延伸到状态栏和主屏幕指示条下面。

### Modifier

常用的 UIKit 属性都有同名的 modifier，每个 modifier 都返回视图本身，所以链式调用会保留具体类型。

```swift
UILabel()
    .text("Title")
    .font(textStyle: .title2)                                   // 跟随动态字体
    .numberOfLines(0)

UILabel()
    .font(UIFont(name: "Avenir-Book", size: 16)!, relativeTo: .body)  // 自定义字体，跟随动态字体
    .lineHeight(24)
    .kerning(0.2)

UIButton(configuration: .filled())
    .title("Save")
    .image(UIImage(systemName: "checkmark"))
    .cornerStyle(.capsule)

UIView()
    .cornerRadius(12)
    .border(color: .separator, width: 1)                        // 跟随深色模式
    .shadow(opacity: 0.1, radius: 8)
```

- 给设置了 `lineHeight` 或 `kerning` 的 label、以及设置了 `placeholder` 的 `UITextView` 改文字时，请用 `text(_:)` modifier，不要直接赋值 `label.text`；直接赋值会跳过它们。
- `cornerStyle`、`baseBackgroundColor` 等 configuration modifier 要求按钮用 `UIButton(configuration:)` 创建。
- `accessibilityCombined()` 让 VoiceOver 把一组 label 读成一个元素。

<details>
<summary>全部属性 modifier</summary>

| 类型 | Modifier |
| --- | --- |
| `UIView` 及其子类 | `configure`、`alpha`、`isHidden`、`isUserInteractionEnabled`、`contentMode`、`tintColor`、`clipsToBounds`、`background`、`cornerRadius`、`border`、`shadow`、`accessibilityLabel`、`accessibilityHint`、`accessibilityTraits`、`isAccessibilityElement`、`accessibilityIdentifier`、`accessibilityCombined`、`contentHuggingPriority`、`compressionResistancePriority` |
| `UILabel` | `text`、`attributedText`、`font`、`font(textStyle:)`、`font(_:relativeTo:)`、`lineHeight`、`kerning`、`textColor`、`numberOfLines`、`textAlignment`、`lineBreakMode`、`adjustsFontSizeToFitWidth`、`minimumScaleFactor` |
| `UIImageView` | `image`、`highlightedImage`、`preferredSymbolConfiguration` |
| `UIControl` 及其子类 | `isEnabled`、`isSelected`、`isHighlighted` |
| `UIButton` | `title`、`titleColor`、`image`、`backgroundImage`，都可以带 `for:` 状态 |
| 带 configuration 的 `UIButton` | `buttonSize`、`cornerStyle`、`contentInsets`、`baseForegroundColor`、`baseBackgroundColor`、`subtitle`、`titleAlignment`、`titlePadding`、`titleFont`、`imagePlacement`、`imagePadding`、`preferredSymbolConfigurationForImage`、`showsActivityIndicator` |
| `UISwitch` | `isOn`、`onTintColor` |
| `UISlider` | `value`、`minimumValue`、`maximumValue`、`minimumTrackTintColor`、`maximumTrackTintColor` |
| `UIStepper` | `value`、`minimumValue`、`maximumValue`、`stepValue` |
| `UISegmentedControl` | `selectedSegmentIndex`、`selectedSegmentTintColor`、`isMomentary` |
| `UIPageControl` | `numberOfPages`、`currentPage`、`hidesForSinglePage`、`pageIndicatorTintColor`、`currentPageIndicatorTintColor` |
| `UIProgressView` | `progress`、`progressTintColor`、`trackTintColor` |
| `UIActivityIndicatorView` | `isAnimating`、`hidesWhenStopped`、`color` |
| `UITextField` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`textColor`、`textAlignment`、`borderStyle`、`clearButtonMode`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType` |
| `UITextView` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`textColor`、`textAlignment`、`textContainerInset`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType`、`isEditable`、`isSelectable`、`isScrollEnabled` |
| `UIScrollView` 及其子类 | `bounces`、`alwaysBounceHorizontal`、`alwaysBounceVertical`、`isPagingEnabled`、`keyboardDismissMode`、`contentInsetAdjustmentBehavior`、`avoidsKeyboard`、`onRefresh` |

</details>

### 事件

```swift
UIButton(configuration: .filled())
    .title("Save")
    .onEvent(.primaryActionTriggered) { [weak self] _ in self?.save() }

UISwitch()
    .onEvent(.valueChanged) { [weak self] toggle in self?.settings.isOn = toggle.isOn }

UIImageView(image: avatar)
    .onTapGesture { [weak self] in self?.showProfile() }
    .onLongPressGesture { [weak self] in self?.showMenu() }
```

- 闭包收到的是控件本身的具体类型，可以直接读取 `isOn` 或 `text`。
- `onTapGesture` 和 `onLongPressGesture` 适用于任何视图，包括 label 和图片。
- 视图会持有它的闭包：捕获 view controller 时请用 `[weak self]`。

### 背景与叠加

```swift
UILabel().text("New").background(.systemYellow)              // 背景色

VStack { content }
    .padding(16)
    .background { GradientView([.systemTeal, .systemBlue]) }   // stack 后面的视图

UIImageView(image: avatar)
    .overlay(alignment: .bottomTrailing, offset: CGPoint(x: 4, y: 4)) { statusDot }
```

没有 `ZStack`：`background { }` 在 stack 后面放一个视图，`overlay { }` 在任何视图前面放一个视图，位置由 `alignment` 决定，例如 `.topTrailing`（默认 `.fill`）。被装饰的视图保持自己的尺寸。

### 滚动视图

```swift
view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    header
    HScroll(spacing: 8, showsIndicators: false) {
        for tag in tags { chip(tag) }
    }
    article
}
.padding(16)
.onRefresh { [weak self] in await self?.reload() }
```

- `VScroll` 和 `HScroll` 滚动它们的元素，滚动距离由元素决定。它们不是惰性的；内容很长或由数据驱动时，请用 [`VList`](#列表)。
- `fillsViewport(true)` 让较短的内容铺满一屏，这样 `Spacer()` 可以把按钮推到底部。
- 要让内容滚到半透明的导航栏下面，用 `safeArea: .horizontal` 和 `.contentInsetAdjustmentBehavior(.automatic)`。

### 表单与键盘

```swift
let email = UITextField()
    .placeholder("Email")
    .borderStyle(.roundedRect)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .returnKeyType(.next)
    .onEvent(.editingDidEndOnExit) { _ in password.becomeFirstResponder() }   // 按 return 跳到下一个输入框

let notes = UITextView()
    .placeholder("Anything we should know?")
    .isScrollEnabled(false)                                                   // 随文字变高

view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    email
    password
    notes
}
.avoidsKeyboard(true)
```

`avoidsKeyboard(true)` 为键盘留出空间，并把正在编辑的输入框滚到可见位置。它适用于任何滚动视图，包括 `VList`。滚动视图之外的视图不会移动。

### 列表

`VList` 是一个列表：行在进入屏幕时才创建，传入新数据时以动画显示变化。它的底层是 `UICollectionView`。

```swift
let list = VList(orders, id: \.id) { [weak self] order in
    ListRow(text: order.title, secondaryText: order.date, image: UIImage(systemName: "bag"))
        .accessories([.disclosureIndicator()])
        .onSelect { self?.show(order) }
        .trailingSwipeActions([
            UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
                self?.delete(order)
                done(true)
            }
        ])
}
.emptyView(UILabel().text("No orders").textColor(.secondaryLabel))
.onReachEnd { [weak self] in self?.loadNextPage() }

view.addContent(list, safeArea: .all)
list.update(newOrders)           // 按 id 插入、删除和移动行
```

- 行有三种：`ListRow(text:secondaryText:image:)` 和 `ListRow(content:)` 是 UIKit 标准样式；`ListRow(MyRowView.self) { $0.update(item) }` 用你自己的视图，每个 cell 创建一次并复用；`ListRow { … }` 用于静态视图，每次重新创建。
- 自己的行视图就是声明了 `ListRowView` 的任意 `UIView`：在 `init` 里搭好结构，再提供一个 `update` 方法。
- 分组页面传入 `sections:`（由 `ListSection(id:header:footer:items:)` 组成）和 `.insetGrouped` 等 `appearance`，之后调用 `update(sections:)`。
- `scrollTo(id)` 滚动到某一行，`onRefresh` 添加下拉刷新。
- 列表自己担任 `delegate`，`onSelect` 依赖它；不要替换。

## 示例应用

`Example/Example.xcodeproj` 是一个用本库搭建的小应用，有四个页面。打开它，选择 `Example` scheme 和一个 iOS 模拟器，然后运行。

<table>
<tr>
<td align="center"><img src="docs/images/example-profile.png" width="200" alt="个人资料卡片页面"><br><a href="Example/Example/ProfileExampleViewController.swift">个人资料卡片</a></td>
<td align="center"><img src="docs/images/example-form.png" width="200" alt="表单页面"><br><a href="Example/Example/FormExampleViewController.swift">表单</a></td>
<td align="center"><img src="docs/images/example-scroll.png" width="200" alt="滚动页面"><br><a href="Example/Example/ScrollExampleViewController.swift">滚动</a></td>
<td align="center"><img src="docs/images/example-list.png" width="200" alt="列表页面"><br><a href="Example/Example/ListExampleViewController.swift">列表</a></td>
</tr>
</table>

## 数据绑定

本库只负责创建视图，状态交给你管理。[DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine) 是一个独立的可选 package，在声明视图的地方把它绑定到 Combine publisher：

```swift
UILabel()
    .bind(\.text, to: viewModel.$title)

UIButton(type: .system)
    .title("Submit")
    .bind(\.isEnabled, to: viewModel.$canSubmit)
    .sink(\.tapPublisher) { [weak self] in self?.submit() }
```

AppKit 版本见姊妹 package [DeclarativeAppKit](https://github.com/nothingsh/DeclarativeAppKit)。

## 更多

- **文档。** 在 Xcode 中打开本 package，选择 Product → Build Documentation，可以看到完整的 API 参考和一篇编写可复用组件的指南。
- **Xcode 预览。** UIKit 视图可以用 `#Preview` 预览，它需要 iOS 17；如果 target 支持更早的版本，给预览加上 `@available(iOS 17, *)`。
- **调试布局。** 库创建的每一条约束都以创建它的 modifier 命名，例如 `DeclarativeUIKit.frame.width` 或 `DeclarativeUIKit.addContent.top`，控制台里的约束冲突因此能看出来源。

## 版本

变更记录见 [CHANGELOG.md](CHANGELOG.md)。版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。从 1.0 起，次版本只新增 API；改名的 API 会以已废弃的形式保留到下一个主版本；最低 iOS 版本只在主版本提高。1.0 之前，次版本可能修改 API，变更记录会给出迁移方法。

## 开发

测试用到 UIKit，所以要在 iOS 模拟器中运行，而不是用 `swift test`：

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

用 `xcrun simctl list devices available` 查找 UDID。

## 许可证

[MIT](LICENSE)，Copyright (c) 2026 Wynn。
