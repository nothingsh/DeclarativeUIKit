# ``DeclarativeUIKit``

Declarative layout for UIKit, built on plain `UIView` and Auto Layout.

## Overview

DeclarativeUIKit builds view hierarchies with result builders and chainable modifiers.
There is no rendering layer of its own: every stack, scroll view and modifier result is a
real `UIView` or subclass, laid out with Auto Layout, so it mixes freely with existing
UIKit code.

```swift
view.addVStack(alignment: .leading, spacing: 4, safeArea: .all) {
    UILabel()
        .text("Ada Lovelace")
        .font(textStyle: .headline)
    UILabel()
        .text("Mathematician")
        .font(textStyle: .subheadline)
        .textColor(.secondaryLabel)
}
.padding(16)
```

## Topics

### Essentials

- <doc:BuildingComponents>

### Stacks

- ``VStack``
- ``HStack``
- ``Spacer``
- ``Divider``
- ``HorizontalAlignment``
- ``VerticalAlignment``

### Scroll views

- ``VScroll``
- ``HScroll``

### Lists

- ``VList``
- ``ListRow``
- ``ListRowView``
- ``ListSection``

### Views

- ``GradientView``

### Building content

- ``UIViewBuilder``

### Layout

- ``LayoutEdges``
- ``LayoutAlignment``
