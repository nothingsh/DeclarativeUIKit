# DeclarativeUIKit

[English](README.md) | [简体中文](README.zh-Hans.md) | **繁體中文**

一個輕量的 UIKit 宣告式版面配置函式庫，以原生 `UIView` 與 Auto Layout 建構，不依賴任何第三方函式庫。

它不引入自訂的繪製層，也不維護平行的視圖階層。你拿到的永遠是真正的 `UIView` 或其子類別，因此能與既有的 UIKit 程式碼自由混用。截圖請見[範例 App](#範例-app)。

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

## 系統需求

- iOS 13.0+
- Swift 5.9+
- 無外部依賴，僅使用系統 UIKit

## 安裝

使用 Swift Package Manager。在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/<owner>/DeclarativeUIKit.git", from: "0.1.0")
]
```

或在 Xcode 中選擇 File → Add Package Dependencies。目前尚未發佈遠端版本，請先以本機 package 的方式引用。

## 用法

### `addContent(_:)`

把視圖掛載到父視圖中，使其填滿父視圖，或在你指定的邊上填滿父視圖的安全區域。

```swift
@discardableResult
func addContent<Content: UIView>(_ content: Content, safeArea: LayoutEdges = []) -> Content
```

```swift
let label = view.addContent(UILabel())   // 回傳這個 UILabel，可以繼續設定
view.addContent(customView)              // 回傳值可以忽略
view.addContent(page, safeArea: .all)    // 保持在安全區域內
```

- 預設把內容的四條邊固定到父視圖的四條邊，使其填滿父視圖的 bounds，並忽略安全區域。
- `safeArea` 中列出的邊改為固定到父視圖的 `safeAreaLayoutGuide`。在這些邊上，內容（包括它繪製的背景）都保持在安全區域內，並隨安全區域的變化（例如旋轉）而調整。只列出部分邊，其餘的邊就能延伸到父視圖邊緣：`safeArea: .horizontal` 讓內容在橫向時避開感測器區域，但仍延伸到狀態列下方。
- 使用 `leadingAnchor` 與 `trailingAnchor`，因此版面會在由右至左的語言中自動鏡像。`LayoutEdges` 與 `padding` 使用的是同一個 option set。
- 回傳傳入的同一個實例，並保留其具體型別。
- 不更動內容本身的尺寸約束。

一個視圖應當只掛載一次。若內容已有 superview 時再次呼叫，會透過 `NSLog` 輸出一則提示，把內容從目前的父視圖移除（這會刪除它與舊階層之間的約束），然後重新掛載。約束不會累積，但內容會移到子視圖順序的最前面。

### Stack

`HStack` 與 `VStack` 沿一條軸排列視圖。兩者都是 `UIStackView` 的子類別，所有原生 stack API 仍然可用。

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

- `alignment` 作用於交叉軸。`VStack` 接受 `HorizontalAlignment`：`leading`、`center`、`trailing`、`fill`。`HStack` 接受 `VerticalAlignment`：`top`、`center`、`bottom`、`firstTextBaseline`、`lastTextBaseline`、`fill`。基線對齊使用 UIKit 本身的基線對齊。`fill` 在 SwiftUI 中沒有對應項，它會讓每個元素在交叉軸上延展填滿。
- `spacing` 預設為 `0`，與 `UIStackView` 一致，因此你看到的間距就是你寫下的間距。這一點與 SwiftUI 不同，SwiftUI 的預設間距取決於上下文。
- `distribution` 使用 UIKit 本身的預設值 `.fill`，透過 modifier 而不是建構器參數來設定。
- 建構 stack 並不會把它掛載到任何地方，元素保持宣告時的順序。

一步完成建構與掛載：

```swift
view.addVStack(alignment: .leading, spacing: 4) {
    name
    role
}
```

`addHStack` 與 `addVStack` 接受與建構器相同的參數，外加 `safeArea`，透過 `addContent` 掛載新建立的 stack 並將其回傳。與 `addContent` 一樣，除非你指定安全區域的邊，否則 stack 會填滿父視圖：

```swift
view.addVStack(spacing: 8, safeArea: .all) {
    title
    body
}
.padding(16)
```

Stack 的 modifier 回傳該 stack，因此可以在建構之後或掛載之後繼續設定：

```swift
view.addVStack {
    name
    role
}
.spacing(12)
.alignment(.leading)
.distribution(.equalSpacing)
```

`spacing(_:)` 與 `distribution(_:)` 適用於任何 `UIStackView`。`alignment(_:)` 依方向分別定義，在 `HStack` 上接受 `VerticalAlignment`，在 `VStack` 上接受 `HorizontalAlignment`。

### 內容閉包

Stack 的內容以 `@UIViewBuilder` 撰寫，它依宣告順序收集視圖，並支援：

| 形式 | 範例 |
| --- | --- |
| 一個視圖 | `UILabel()` |
| 可選視圖 | `subtitle`，其中 `subtitle: UILabel?`，為 `nil` 時不產生任何元素 |
| 視圖陣列 | `rows`，其中 `rows: [UIView]` |
| `if` 以及 `if` / `else` | `if isEditing { field } else { label }` |
| `switch` | `switch state { case .empty: placeholder; default: list }` |
| `for` | `for item in items { row(item) }` |
| `if #available` | `if #available(iOS 14, *) { modernView }` |
| 什麼都不寫 | `VStack {}` |

不是 `UIView` 的運算式會導致編譯失敗，而不會被悄悄丟棄。

一個 `UIView` 只能屬於一個父視圖，因此同一個實例不能在同一個內容閉包中出現兩次。這屬於程式錯誤：它會帶著說明訊息觸發 trap，而不是悄悄合併成一個元素。

### 屬性 modifier

屬性 modifier 設定接收者的某個 UIKit 屬性，並以 `Self` 回傳同一個實例，因此鏈式呼叫中具體型別得以保留，通用 modifier 之後仍能繼續使用特定型別的 modifier。同一屬性被設定兩次時，以最後一次為準。

```swift
let title = UILabel()
    .text("Title")
    .font(textStyle: .title2)
    .numberOfLines(0)
    .accessibilityIdentifier("title")

title.text("Updated")   // 之後的更新透過同一個參考進行
```

| 型別 | Modifier |
| --- | --- |
| `UIView` 及其任何子類別 | `configure`、`alpha`、`isHidden`、`isUserInteractionEnabled`、`contentMode`、`tintColor`、`clipsToBounds`、`accessibilityLabel`、`accessibilityIdentifier` |
| `UILabel` | `text`、`attributedText`、`font`、`font(textStyle:)`、`textColor`、`numberOfLines`、`textAlignment`、`lineBreakMode` |
| `UIImageView` | `image`、`highlightedImage` |
| `UIControl` 及其任何子類別 | `isEnabled`、`isSelected`、`isHighlighted` |
| `UIButton` | `title`、`titleColor`、`image`、`backgroundImage`，皆帶 `for state: UIControl.State = .normal` |
| `UISwitch` | `isOn`、`onTintColor` |
| `UISlider` | `value`、`minimumValue`、`maximumValue`、`minimumTrackTintColor`、`maximumTrackTintColor` |
| `UITextField` | `text`、`attributedText`、`placeholder`、`font`、`font(textStyle:)`、`textColor`、`textAlignment`、`keyboardType`、`returnKeyType`、`isSecureTextEntry` |
| `UITextView` | `text`、`attributedText`、`font`、`font(textStyle:)`、`textColor`、`textAlignment`、`keyboardType`、`returnKeyType`、`isSecureTextEntry`、`isEditable`、`isSelectable`、`isScrollEnabled` |

每個 modifier 接受的型別與它所設定的 UIKit 屬性相同。它們並不是 UIKit 的完整鏡像；其他屬性請使用 `configure`，它會以具體型別把視圖交給你：

```swift
let avatar = UIImageView()
    .image(photo)
    .contentMode(.scaleAspectFill)
    .clipsToBounds(true)
    .configure { $0.layer.cornerRadius = 24 }
```

- `font(textStyle:)` 使用該文字樣式對應的系統字體，並開啟 `adjustsFontForContentSizeCategory`，因此 label 會跟隨動態字體（Dynamic Type）。`font(_:)` 只設定字體，與 UIKit 屬性完全一致。
- `numberOfLines(0)` 允許 label 換行；在 Auto Layout 下，它的高度隨可用寬度變化。

按鈕的 modifier 依控制項狀態分別設定值，透過 UIKit 的 `setTitle(_:for:)` 及同類方法實作，因此各個狀態之間不會互相覆蓋。沒有單獨設定值的狀態會退回 `.normal`，與 UIKit 一致。本函式庫不使用 `UIButton.Configuration`。

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

- 事件使用 UIKit 本身的 target–action：`play.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)`。modifier 不會加入 target，也沒有閉包形式的事件處理。
- 透過 `isOn` 或 `value` 設定值不屬於使用者事件，不會送出 `.valueChanged`，與 UIKit 屬性一致。
- `UISlider` 會把 `value` 限制在目前的範圍內，因此請先設定 `minimumValue` 與 `maximumValue`，再設定 `value`。

文字輸入的 modifier 以同樣的方式設定 `UITextField` 與 `UITextView`；`font(textStyle:)` 與 label 一樣跟隨動態字體。

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

- `placeholder` 只存在於 `UITextField` 上，因為 UIKit 中的 `UITextView` 沒有佔位文字，本函式庫也不會額外加入。
- 文字視圖的尺寸取決於 `isScrollEnabled`。為 `false` 時，它在給定寬度下與文字一樣高，並隨文字增加而變高，就像多行 label。為 `true`（UIKit 的預設值）時，它沒有固有高度：需要透過 `frame` 或約束給它一個高度，較長的文字會在其內部捲動。
- 委派、編輯行為與鍵盤仍然是 UIKit 自己的。modifier 不設定委派，也沒有雙向繫結、輸入驗證或鍵盤避讓。

### Padding

Padding 是 stack 的 modifier。它設定 stack 的 `directionalLayoutMargins`，開啟 `isLayoutMarginsRelativeArrangement` 並關閉 `insetsLayoutMarginsFromSafeArea`，然後回傳同一個 stack。

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
stack.padding(horizontal: 16, vertical: 12)                   // 每條軸一個值
stack.padding(top: 8, leading: 16, bottom: 24, trailing: 12)  // 每條邊都不同
stack.padding(.top, 24, others: 8)                            // 單獨一條邊，其餘相同
```

- Padding 計入 stack 的尺寸：內容為 20 × 30 的 stack，加上 `.padding(10)` 後為 40 × 50。
- 它的行為類似屬性。`padding(_:_:)` 只改變你指定的邊，其餘的邊保持不變，因此 `.padding(.horizontal, 16).padding(.vertical, 12)` 會設定全部四條邊。其他形式都在一次呼叫中設定全部四條邊。後一次呼叫會取代先前的值，而不是疊加。
- `LayoutEdges` 是由 `top`、`leading`、`bottom`、`trailing` 以及 `horizontal`、`vertical`、`all` 組成的 option set。水平方向的邊是 `leading` 與 `trailing`，因此在由右至左的語言中會鏡像。
- Padding 是固定留白，從不包含安全區域。要讓內容保持在安全區域內，請以 `safeArea` 掛載；請參閱 [`addContent(_:)`](#addcontent_)。
- 要給單一視圖加上 padding，把它放進 stack：`VStack { label }.padding(16)`。

### Frame

`frame` 在視圖本身加上尺寸約束，並以 `Self` 回傳它，因此鏈式呼叫保留具體型別。與 SwiftUI 一樣，它有固定尺寸與尺寸範圍兩種形式。

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

- 它把 `translatesAutoresizingMaskIntoConstraints` 設為 `false`，並使用 required 優先權的 `widthAnchor` / `heightAnchor` 約束：固定長度用 `==`，最小值用 `>=`，最大值用 `<=`。
- 每次呼叫會重新定義它指定的軸，另一條軸保持不變。先呼叫 `frame(width: 100)` 再呼叫 `frame(width: 120)`，更新的是同一條約束。固定寬度會移除先前的最小或最大寬度，範圍形式會移除先前的固定寬度，因此兩者之間切換不會衝突。在範圍形式中，某條軸只指定一個界限時會移除另一個：在 `frame(maxWidth: 200)` 之後呼叫 `frame(minWidth: 40)`，只保留最小值。
- 最大值可以傳入 `.infinity`，表示沒有上限，不會加入約束。
- `frame(aspectRatio:)` 保持寬度等於該比例乘以高度，與 SwiftUI 一致（`16 / 9` 表示寬大於高）。把它與固定的寬度或高度搭配使用，即可推導出另一邊的長度；若寬高也都固定，則會衝突。重複呼叫會取代比例，傳入 `nil` 則移除。
- 只會更新或移除 `frame` 自己建立的約束。你自行加入的尺寸約束永遠不會被更動。
- 負數或非有限的固定長度或最小值、負數或 NaN 的最大值、最小值大於最大值，以及不是有限正數的長寬比，都屬於程式錯誤，會帶著說明訊息觸發 trap。

### Background 與 overlay

`background(_:)` 設定視圖本身的 `backgroundColor`。視圖形式的裝飾會作為被裝飾視圖的子視圖加入，並以約束固定。所有形式都以 `Self` 回傳同一個視圖。不會插入容器視圖，也沒有 `ZStack`。

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

- `background(_:)` 適用於任何視圖，只設定 `backgroundColor`；它是本函式庫中對應這個屬性的 modifier。在 iOS 13 上 stack 不會繪製自己的 `backgroundColor`；如需支援 iOS 13，請改用 `background { ... }` 給 stack 放一個帶顏色的視圖。
- `background { ... }` 是 stack 的 modifier。該視圖位於 stack 內容的後方，在預設的 `.fill` 下覆蓋整個 stack（包括 padding）。要在單一視圖後方放背景視圖，把該視圖放進 stack：`VStack { label }.padding(8).background { badgeShape }`。
- `overlay` 適用於任何視圖，位於該視圖現有子視圖的前方，在預設的 `.fill` 下覆蓋整個視圖。之後加入的子視圖（例如之後追加的 arranged subview）會位於它的前方。
- 被裝飾視圖的內容決定其尺寸。在 `.fill` 下，裝飾視圖的 hugging 與 compression resistance 會設為 `.fittingSizeLevel`，因此一張大圖不會把視圖撐大。但若裝飾視圖自己的子視圖要求最小尺寸（例如由數個 label 組成的 stack），仍然可能撐大。
- `LayoutAlignment` 的值為 `fill`、`center`、`top`、`bottom`、`leading`、`trailing`、`topLeading`、`topTrailing`、`bottomLeading` 或 `bottomTrailing`。`fill` 把裝飾延展覆蓋整個視圖。其他值保留裝飾本身的尺寸，並把它放在對應位置。`leading` 與 `trailing` 在由右至左的語言中會鏡像。
- 視圖裝飾會疊加，與 SwiftUI 一致：後加入的 `background { ... }` 位於更後方，後加入的 `overlay` 位於更前方。
- 裝飾視圖應當只加入一次。若它已有 superview，會輸出提示，先將其移除（同時刪除其既有約束），再重新加入。
- 觸控遵循 UIKit 的命中測試。背景位於內容後方，因此從不遮擋控制項。可互動的 overlay 會接收其 bounds 內的觸控，並遮擋其後的內容；使用 `.isUserInteractionEnabled(false)` 讓觸控穿透。裝飾視圖不會被裁切，但落在被裝飾視圖 bounds 之外的觸控不會抵達它，這與 UIKit 的一般行為相同。

### Spacer 與版面優先權

`Spacer` 是一個空視圖，它沿所在 stack 的軸佔據剩餘長度。版面優先權透過兩個 modifier 設定，適用於任何視圖，並以 `Self` 回傳同一個視圖。

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

- Spacer 會先於有內容的視圖讓步：在 stack 的軸上，它的 hugging 優先權為 `.fittingSizeLevel`，因此它吸收多餘的空間，其他視圖保持固有尺寸。它在交叉軸上不會變大。
- 同一個 stack 中的多個 spacer 平分多餘的空間。
- `minLength` 是 required 的最小值。當 stack 放不下時，其他視圖依各自的 compression resistance 縮小；用 `compressionResistancePriority` 調低某個視圖的優先權，即可決定哪個視圖先讓步。如果 stack 中的固定尺寸根本放不下，required 約束就會衝突，UIKit 會打破其中一條，這與任何 Auto Layout 版面一樣。
- 在無界的軸上（例如捲動視圖的捲動軸）沒有剩餘長度，因此 spacer 的長度只有 `minLength`。
- 軸是在 spacer 被加入 `UIStackView` 時讀取的，無論是透過內容閉包還是透過 `addArrangedSubview`。之後修改該 stack 的 `axis` 不會被跟隨。不在 `UIStackView` 中的 spacer 不起作用，把它加入非 stack 視圖時會輸出提示。
- 需要固定間隔時，請對空視圖使用 `frame`，或使用 stack 的 `spacing`。
- 這些優先權是 UIKit 的 content hugging 與 compression resistance，而不是 SwiftUI 的 `layoutPriority`：它們只在原本會依固有內容尺寸決定大小的視圖之間起作用。

### 捲動視圖

`HScroll` 與 `VScroll` 是可捲動的 stack：你列出的元素由內建的 `HStack` 或 `VStack` 排列，因此不必在裡面再寫一個 stack。兩者都是 `UIScrollView` 的子類別，因此委派、`contentOffset` 以及所有原生捲動視圖 API 仍然可用；本函式庫從不設定委派。

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

- `alignment`、`spacing` 與內容閉包的意義和 `HStack`、`VStack` 相同，預設值也相同。`addHScroll` 與 `addVScroll` 接受相同的參數，外加 `safeArea`，透過 `addContent` 掛載並回傳捲動視圖。
- 內建 stack 的四邊固定到 `contentLayoutGuide`，因此由元素決定可捲動的長度。在另一條軸上，stack 固定到 `frameLayoutGuide`：`VScroll` 的 stack 與捲動視圖等寬，`HScroll` 的 stack 與捲動視圖等高，`alignment` 決定元素在這條軸上的位置。當捲動視圖尺寸改變或某個元素改變（例如 label 換行成更多行）時，content size 會隨之更新。
- 比捲動視圖短的內容保持本身的長度，不會被延展填滿。空的 `VScroll {}` 在捲動軸上的 content size 為零。
- 捲動軸是無界的，因此捲動視圖中的 `Spacer` 長度只有 `minLength`。
- 捲動視圖在捲動軸上沒有固有尺寸。巢狀放在 stack 中時，`HScroll` 的高度由元素決定，但寬度需要由外部給定，`VScroll` 則相反：請像上面那樣在外層 stack 中使用 `.fill` 對齊，或使用 `frame`。若使用 `.leading`、`.center` 或 `.trailing`，它的長度會塌縮為零。
- `showsIndicators` 控制捲動方向上的指示器。
- `contentInsetAdjustmentBehavior` 為 `.never`，因此捲動視圖不會自動加入安全區域 inset，內容從其邊緣開始。以 `safeArea` 掛載即可讓整個捲動視圖保持在安全區域內；或者使用 `.contentInsetAdjustmentBehavior(.automatic)`，讓內容可以捲動到導覽列等列的下方，同時起始位置避開它們。
- 回彈保持 UIKit 的預設行為：比捲動視圖短的內容不會回彈，除非你開啟 `alwaysBounceVertical` 或 `alwaysBounceHorizontal`。

Modifier 以 `Self` 回傳同一個捲動視圖：

| 型別 | Modifier |
| --- | --- |
| `HScroll`、`VScroll` | `showsIndicators`、`alignment`、`spacing`、`padding(_ length:)`、`padding(_ edges:_ length:)` |
| `UIScrollView` | `bounces`、`alwaysBounceHorizontal`、`alwaysBounceVertical`、`contentInsetAdjustmentBehavior` |

`alignment`、`spacing` 與 `padding` 設定的是內建 stack。Padding 位於捲動內容之內，因此會隨元素一起捲動，並計入 content size。其他 stack 設定，例如 `distribution`、其他形式的 `padding` 或 stack 的 `background`，請使用唯讀的 `stack` 屬性：

```swift
VScroll { rows }
    .configure { $0.stack.distribution(.equalSpacing).background { card } }
```

鍵盤避讓與可重複使用的清單不在本函式庫範圍內；較長、需要重複使用的內容請使用 `UICollectionView` 或 `UITableView`。

## 範例 App

`Example/Example.xcodeproj` 是一個以本機 package 方式使用本函式庫的小型 iOS App。在 Xcode 中開啟它，選擇 `Example` scheme 與一個 iOS 模擬器，然後執行。以下的程式碼片段節錄自它的三個畫面。

### 個人資料卡片

程式碼的結構與畫面的結構一致。狀態徽章透過 `overlay` 附加到大頭貼上，不需要包裝視圖，也不需要 `ZStack`。`bio` 與 `status` 都是一般屬性：按鈕直接修改它們，Auto Layout 會調整卡片的大小。不會重建任何視圖。

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

// 之後，在按鈕的 action 中：
bio.text(Self.longBio)
status.background(.systemGray)
```

</td>
<td width="300">
<img src="docs/images/example-profile.png" width="300" alt="個人資料卡片畫面">
</td>
</tr>
</table>

可重複使用的樣式只是一個以 modifier 組成的函式。`card()` 是範例 App 自己的輔助方法，不屬於本函式庫：

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

### 表單

控制項就是一般的 `UITextField`、`UISwitch` 與 `UISlider`，以 modifier 設定並作為屬性持有。事件使用 UIKit 本身的 target–action 與委派。`Spacer` 把開關與數值推到尾端邊緣。

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
<img src="docs/images/example-form.png" width="300" alt="表單畫面">
</td>
</tr>
</table>

### 捲動

`VScroll` 中巢狀放入 `HScroll` 列。內容閉包支援 `for` 迴圈，回傳 `UIView` 的小函式可以像其他視圖一樣組合。點一下 *Add row* 會向作為屬性持有的 stack 追加一列，捲動視圖的 content size 隨之更新。

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
<img src="docs/images/example-scroll.png" width="300" alt="捲動畫面">
</td>
</tr>
</table>

所有文字都使用 `font(textStyle:)`，因此各畫面會跟隨動態字體，並能適應旋轉。內容閉包只執行一次；之後的變化透過視圖本身完成，而不是透過資料繫結。

每個畫面都以 `safeArea: .all` 掛載其捲動視圖，因此內容會避開導覽列、主畫面指示條以及橫向時的感測器區域，而畫面的背景顏色仍然鋪滿整個螢幕。

範例 App 的部署目標是 iOS 15.0，這是目前 Xcode 能建置的最低版本；請參閱[已知限制](#已知限制)。

## 發展藍圖

目前已提供：Swift package 基礎、`addContent` 掛載、`UIViewBuilder` 與 `HStack`、`VStack`，`UIView`、`UILabel`、`UIImageView`、`UIControl`、`UIButton`、`UISwitch`、`UISlider`、`UITextField` 與 `UITextView` 的屬性 modifier，stack 的 `padding`，`frame` 尺寸約束，`background` 與 `overlay`，`Spacer` 與版面優先權 modifier，`HScroll` / `VScroll`，安全區域掛載，以及一個範例 App。

1.0 之前 API 可能會有所變動。

## 已知限制

本 package 宣告的最低版本是 iOS 13，新 API 皆依 iOS 13 的可用性審查過，但從未針對 iOS 13 本身建置或執行過，因為目前的工具鏈已不再支援這個部署目標。目前經過驗證的，是在較新 iOS 版本上的編譯與測試。

## 開發

測試會呼叫 UIKit，必須在 iOS 模擬器中執行。在 macOS 上執行 `swift test` 不是本函式庫有效的測試方式。

```sh
IOS_SIMULATOR_ID=<simulator UDID> scripts/test-ios.sh
```

使用 `xcrun simctl list devices available` 查詢 UDID。未設定 `IOS_SIMULATOR_ID` 時，指令碼會列出已安裝的裝置並結束。它會轉送額外的 `xcodebuild` 參數，並把日誌與測試結果寫入 `.build/validation/`。

## 授權條款

[MIT](LICENSE)，Copyright (c) 2026 Wynn.
