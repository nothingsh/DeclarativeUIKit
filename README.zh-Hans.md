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
  - [Padding 与 frame](#padding-与-frame)
  - [Background 与 overlay](#background-与-overlay)
  - [Spacer](#spacer)
  - [滚动视图](#滚动视图)
- [数据绑定](#数据绑定)
- [示例应用](#示例应用)
  - [个人资料卡片](#个人资料卡片)
  - [表单](#表单)
  - [滚动](#滚动)
- [已知限制](#已知限制)
- [开发](#开发)
- [许可证](#许可证)

## 安装

需要 iOS 13.0+ 与 Swift 5.9+。使用 Swift Package Manager 添加：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.1.0")
]
```

或在 Xcode 中选择 File → Add Package Dependencies，输入 `https://github.com/nothingsh/DeclarativeUIKit`。

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
- `spacing` 默认为 `0`，因此你看到的间距就是你写下的间距。之后可以用 `.spacing(_:)`、`.alignment(_:)` 与 `.distribution(_:)` 修改。
- 内容闭包接受视图、可选视图、数组、`if` / `else`、`switch`、`for` 与 `if #available`。

### 属性 modifier

每个 modifier 设置一个 UIKit 属性，并以 `Self` 返回该视图，因此链式调用保留具体类型。

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)                   // 跟随 Dynamic Type
    .numberOfLines(0)

let play = UIButton(type: .system)
    .title("Play")
    .title("Pause", for: .selected)

let avatar = UIImageView()
    .image(photo)
    .configure { $0.layer.cornerRadius = 24 }   // 没有对应 modifier 的属性
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

`font(textStyle:)` 跟随 Dynamic Type，`font(_:)` 则设置固定字体。按钮的 modifier 为每个控件状态各设置一个值。事件仍使用 UIKit 自己的 target–action 与代理。

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

- `background(_:)` 设置视图自身的 `backgroundColor`。在 iOS 13 上 stack 不会绘制它，因此请改用 `background { ... }` 给 stack 放一个带颜色的视图。
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
- `contentInsetAdjustmentBehavior` 为 `.never`，因此内容从滚动视图的边缘开始。用 `safeArea` 挂载滚动视图可以让它保持在安全区内。

## 数据绑定

DeclarativeUIKit 只负责布局：内容闭包只运行一次，库本身不提供绑定。之后需要变化或上报事件的视图，必须存成属性，再手动连接。

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

## 已知限制

本 package 声明的最低版本是 iOS 13，新 API 都按 iOS 13 的可用性审查过，但从未针对 iOS 13 本身构建或运行过，因为当前的工具链已不再支持这个部署目标。目前经过验证的，是在较新 iOS 版本上的编译与测试。

## 开发

测试会调用 UIKit，必须在 iOS 模拟器中运行；在 macOS 上执行 `swift test` 不是有效的测试方式。

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

使用 `xcrun simctl list devices available` 查找 UDID。

## 许可证

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
