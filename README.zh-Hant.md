<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/declarative-uikit-dark.svg">
    <img src="docs/images/declarative-uikit-light.svg" alt="DeclarativeUIKit — Declarative layout for UIKit, on plain UIView." width="850">
  </picture>
</p>

# DeclarativeUIKit

[English](README.md) | [简体中文](README.zh-Hans.md) | **繁體中文**

像寫 SwiftUI 一樣寫 UIKit 版面，得到的仍是一般的 `UIView`。

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/hero-card-dark.png">
    <img src="docs/images/hero-card.png" width="420" alt="一張個人資料卡片：大頭貼、姓名、職業、分隔線與一段簡介">
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

## 為什麼用 DeclarativeUIKit

- **它仍然是 UIKit。** `VStack` 就是 `UIStackView`，`VScroll` 就是 `UIScrollView`，每個 modifier 都回傳呼叫它的那個視圖。可以與既有程式碼、view controller、第三方視圖自由混用。
- **程式碼的樣子就是畫面的樣子。** 程式碼怎麼巢狀，畫面上就怎麼巢狀；Auto Layout 約束由函式庫替你寫。
- **所見即所得。** 不設定 spacing 就是 0，不加 padding 就沒有留白，只有你指定的邊才受安全區域約束。

它很小，沒有任何相依套件，支援 iOS 15 以上。

## 安裝

使用 Swift Package Manager 加入：

```swift
dependencies: [
    .package(url: "https://github.com/nothingsh/DeclarativeUIKit.git", from: "0.9.0")
]
```

或在 Xcode 中選擇 File → Add Package Dependencies，輸入 `https://github.com/nothingsh/DeclarativeUIKit`。需要 iOS 15.0+ 與 Swift 5.9+。

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

一開始就要知道的兩件事：

- **內容閉包只執行一次。** 它負責建立視圖，不會重新繪製。之後要修改，就把視圖存成屬性（如上面的 `bio`）再修改它，或者用 [DeclarativeCombine](#資料繫結) 繫結。
- **沒有 modifier 的屬性也能設定。** `configure { $0.layer.zPosition = 1 }` 可以在鏈式呼叫中執行任意 UIKit 程式碼。

## 指南

### Stack

```swift
VStack(alignment: .leading, spacing: 8) {
    title
    if let subtitle { subtitle }
    for tag in tags { chip(tag) }
    HStack(spacing: 8) {
        icon
        Spacer()          // 佔據剩下的空間
        badge
    }
    Divider()             // 橫跨 stack 的細線
    footer
}
```

- `alignment` 決定元素在交叉方向上如何對齊：`VStack` 用 `leading`、`center`、`trailing` 或 `fill`；`HStack` 用 `top`、`center`、`bottom`、文字基線或 `fill`。`spacing` 預設為 0。
- 內容閉包可以寫視圖、可選值、陣列、`if`、`switch`、`for` 與 `if #available`。之後要換掉元素，對 stack 呼叫 `replaceContent { … }`。
- 之後要修改 stack，用 `.spacing(_:)`、`.spacing(_:after:)`、`.alignment(_:)` 與 `.distribution(_:)`。

### 尺寸與 padding

```swift
VStack { name; role }
    .padding(16)                          // 四條邊
    .padding(.horizontal, 24)             // 只改這些邊

UIImageView().frame(width: 48, height: 48)
UIButton().frame(minWidth: 88)
UIImageView().frame(width: 320).frame(aspectRatio: 16 / 9)

title.compressionResistancePriority(.defaultLow, for: .horizontal)
```

- `padding` 是 stack 的 modifier。要給單一視圖加 padding，就把它放進一個 stack。
- `frame` 加入尺寸約束；對同一個方向再次呼叫會取代先前的約束。

### 把視圖放到畫面上

```swift
view.addContent(page)                          // 鋪滿父視圖
view.addContent(page, safeArea: .all)          // 留在安全區域內
view.addVStack(spacing: 8, safeArea: .top) {   // 建立 stack 並加入
    title
    body
}
```

`addContent`、`addHStack`、`addVStack`、`addHScroll` 與 `addVScroll` 把視圖的四條邊固定到父視圖。`safeArea` 中列出的邊改為停在安全區域邊緣，所以背景仍然可以延伸到狀態列與主畫面指示條下方。

### Modifier

常用的 UIKit 屬性都有同名的 modifier，每個 modifier 都回傳視圖本身，所以鏈式呼叫會保留具體型別。

```swift
UILabel()
    .text("Title")
    .font(textStyle: .title2)                                   // 跟隨動態字體
    .numberOfLines(0)

UILabel()
    .font(UIFont(name: "Avenir-Book", size: 16)!, relativeTo: .body)  // 自訂字型，跟隨動態字體
    .lineHeight(24)
    .kerning(0.2)

UIButton(configuration: .filled())
    .title("Save")
    .image(UIImage(systemName: "checkmark"))
    .cornerStyle(.capsule)

UIView()
    .cornerRadius(12)
    .border(color: .separator, width: 1)                        // 跟隨深色模式
    .shadow(opacity: 0.1, radius: 8)
```

- 替設定了 `lineHeight` 或 `kerning` 的 label、以及設定了 `placeholder` 的 `UITextView` 改文字時，請用 `text(_:)` modifier，不要直接指派 `label.text`；直接指派會略過它們。
- `cornerStyle`、`baseBackgroundColor` 等 configuration modifier 要求按鈕以 `UIButton(configuration:)` 建立。
- `accessibilityCombined()` 讓 VoiceOver 把一組 label 讀成一個元素。

<details>
<summary>所有屬性 modifier</summary>

| 型別 | Modifier |
| --- | --- |
| `UIView` 及其子類別 | `configure`、`alpha`、`isHidden`、`isUserInteractionEnabled`、`contentMode`、`tintColor`、`clipsToBounds`、`background`、`cornerRadius`、`border`、`shadow`、`accessibilityLabel`、`accessibilityHint`、`accessibilityTraits`、`isAccessibilityElement`、`accessibilityIdentifier`、`accessibilityCombined`、`contentHuggingPriority`、`compressionResistancePriority` |
| `UILabel` | `text`、`attributedText`、`font`、`font(textStyle:)`、`font(_:relativeTo:)`、`lineHeight`、`kerning`、`textColor`、`numberOfLines`、`textAlignment`、`lineBreakMode`、`adjustsFontSizeToFitWidth`、`minimumScaleFactor` |
| `UIImageView` | `image`、`highlightedImage`、`preferredSymbolConfiguration` |
| `UIControl` 及其子類別 | `isEnabled`、`isSelected`、`isHighlighted` |
| `UIButton` | `title`、`titleColor`、`image`、`backgroundImage`，都可以帶 `for:` 狀態 |
| 帶 configuration 的 `UIButton` | `buttonSize`、`cornerStyle`、`contentInsets`、`baseForegroundColor`、`baseBackgroundColor`、`subtitle`、`titleAlignment`、`titlePadding`、`titleFont`、`imagePlacement`、`imagePadding`、`preferredSymbolConfigurationForImage`、`showsActivityIndicator` |
| `UISwitch` | `isOn`、`onTintColor` |
| `UISlider` | `value`、`minimumValue`、`maximumValue`、`minimumTrackTintColor`、`maximumTrackTintColor` |
| `UIStepper` | `value`、`minimumValue`、`maximumValue`、`stepValue` |
| `UISegmentedControl` | `selectedSegmentIndex`、`selectedSegmentTintColor`、`isMomentary` |
| `UIPageControl` | `numberOfPages`、`currentPage`、`hidesForSinglePage`、`pageIndicatorTintColor`、`currentPageIndicatorTintColor` |
| `UIProgressView` | `progress`、`progressTintColor`、`trackTintColor` |
| `UIActivityIndicatorView` | `isAnimating`、`hidesWhenStopped`、`color` |
| `UITextField` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`textColor`、`textAlignment`、`borderStyle`、`clearButtonMode`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType` |
| `UITextView` | `text`、`attributedText`、`placeholder`、`attributedPlaceholder`、`font`、`textColor`、`textAlignment`、`textContainerInset`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`autocapitalizationType`、`autocorrectionType`、`textContentType`、`isEditable`、`isSelectable`、`isScrollEnabled` |
| `UIScrollView` 及其子類別 | `bounces`、`alwaysBounceHorizontal`、`alwaysBounceVertical`、`isPagingEnabled`、`keyboardDismissMode`、`contentInsetAdjustmentBehavior`、`avoidsKeyboard`、`onRefresh` |

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

- 閉包收到的是控制項本身的具體型別，可以直接讀取 `isOn` 或 `text`。
- `onTapGesture` 與 `onLongPressGesture` 適用於任何視圖，包括 label 與圖片。
- 視圖會持有它的閉包：捕捉 view controller 時請用 `[weak self]`。

### 背景與疊加

```swift
UILabel().text("New").background(.systemYellow)              // 背景顏色

VStack { content }
    .padding(16)
    .background { GradientView([.systemTeal, .systemBlue]) }   // stack 後方的視圖

UIImageView(image: avatar)
    .overlay(alignment: .bottomTrailing, offset: CGPoint(x: 4, y: 4)) { statusDot }
```

沒有 `ZStack`：`background { }` 在 stack 後方放一個視圖，`overlay { }` 在任何視圖前方放一個視圖，位置由 `alignment` 決定，例如 `.topTrailing`（預設 `.fill`）。被裝飾的視圖保持自己的尺寸。

### 捲動視圖

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

- `VScroll` 與 `HScroll` 捲動它們的元素，捲動距離由元素決定。它們不是惰性的；內容很長或由資料驅動時，請用 [`VList`](#清單)。
- `fillsViewport(true)` 讓較短的內容鋪滿一個畫面，這樣 `Spacer()` 可以把按鈕推到底部。
- 要讓內容捲到半透明的導覽列下方，用 `safeArea: .horizontal` 與 `.contentInsetAdjustmentBehavior(.automatic)`。

### 表單與鍵盤

```swift
let email = UITextField()
    .placeholder("Email")
    .borderStyle(.roundedRect)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .returnKeyType(.next)
    .onEvent(.editingDidEndOnExit) { _ in password.becomeFirstResponder() }   // 按 return 跳到下一個輸入欄位

let notes = UITextView()
    .placeholder("Anything we should know?")
    .isScrollEnabled(false)                                                   // 隨文字變高

view.addVScroll(alignment: .fill, spacing: 12, safeArea: .all) {
    email
    password
    notes
}
.avoidsKeyboard(true)
```

`avoidsKeyboard(true)` 為鍵盤留出空間，並把正在編輯的輸入欄位捲到可見位置。它適用於任何捲動視圖，包括 `VList`。捲動視圖之外的視圖不會移動。

### 清單

`VList` 是一個清單：列在進入畫面時才建立，傳入新資料時以動畫顯示變化。它的底層是 `UICollectionView`。

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
list.update(newOrders)           // 依 id 插入、刪除與移動列
```

- 列有三種：`ListRow(text:secondaryText:image:)` 與 `ListRow(content:)` 是 UIKit 標準樣式；`ListRow(MyRowView.self) { $0.update(item) }` 用你自己的視圖，每個 cell 建立一次並重複使用；`ListRow { … }` 用於靜態視圖，每次重新建立。
- 自己的列視圖就是宣告了 `ListRowView` 的任意 `UIView`：在 `init` 裡建好結構，再提供一個 `update` 方法。
- 分組畫面傳入 `sections:`（由 `ListSection(id:header:footer:items:)` 組成）與 `.insetGrouped` 等 `appearance`，之後呼叫 `update(sections:)`。
- `scrollTo(id)` 捲動到某一列，`onRefresh` 加入下拉更新。
- 清單自己設定了 `delegate`，`onSelect` 和 `onReachEnd` 依賴它；請勿取代。

## 範例 App

`Example/Example.xcodeproj` 是一個用本函式庫建立的小 App，有四個畫面。開啟它，選擇 `Example` scheme 與一個 iOS 模擬器，然後執行。

<table>
<tr>
<td align="center"><img src="docs/images/example-profile.png" width="200" alt="個人資料卡片畫面"><br><a href="Example/Example/ProfileExampleViewController.swift">個人資料卡片</a></td>
<td align="center"><img src="docs/images/example-form.png" width="200" alt="表單畫面"><br><a href="Example/Example/FormExampleViewController.swift">表單</a></td>
<td align="center"><img src="docs/images/example-scroll.png" width="200" alt="捲動畫面"><br><a href="Example/Example/ScrollExampleViewController.swift">捲動</a></td>
<td align="center"><img src="docs/images/example-list.png" width="200" alt="清單畫面"><br><a href="Example/Example/ListExampleViewController.swift">清單</a></td>
</tr>
</table>

## 資料繫結

本函式庫只負責建立視圖，狀態交給你管理。[DeclarativeCombine](https://github.com/nothingsh/DeclarativeCombine) 是一個獨立的選用 package，在宣告視圖的地方把它繫結到 Combine publisher：

```swift
UILabel()
    .bind(\.text, to: viewModel.$title)

UIButton(type: .system)
    .title("Submit")
    .bind(\.isEnabled, to: viewModel.$canSubmit)
    .sink(\.tapPublisher) { [weak self] in self?.submit() }
```

AppKit 版本請見姊妹 package [DeclarativeAppKit](https://github.com/nothingsh/DeclarativeAppKit)。

## 更多

- **文件。** 在 Xcode 中開啟本 package，選擇 Product → Build Documentation，可以看到完整的 API 參考與一篇撰寫可重複使用元件的指南。
- **Xcode 預覽。** UIKit 視圖可以用 `#Preview` 預覽，它需要 iOS 17；如果 target 支援更早的版本，請為預覽加上 `@available(iOS 17, *)`。
- **除錯版面。** 函式庫建立的每一條約束都以建立它的 modifier 或視圖命名，例如 `DeclarativeUIKit.frame.width` 或 `DeclarativeUIKit.addContent.top`，主控台中的約束衝突因此能看出來源。

## 版本

變更記錄請見 [CHANGELOG.md](CHANGELOG.md)。版本號遵循[語意化版本](https://semver.org/lang/zh-TW/)。從 1.0 起，次版本只新增 API；改名的 API 會以已棄用的形式保留到下一個主版本；最低 iOS 版本只在主版本提高。1.0 之前，次版本可能修改 API，變更記錄會說明遷移方式。

## 開發

測試用到 UIKit，所以要在 iOS 模擬器中執行，而不是用 `swift test`：

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

用 `xcrun simctl list devices available` 尋找 UDID。

## 授權

[MIT](LICENSE)，Copyright (c) 2026 Wynn。
