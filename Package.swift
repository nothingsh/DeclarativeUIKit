// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DeclarativeUIKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DeclarativeUIKit", targets: ["DeclarativeUIKit"])
    ],
    dependencies: [],
    targets: [
        .target(name: "DeclarativeUIKit"),
        .testTarget(name: "DeclarativeUIKitTests", dependencies: ["DeclarativeUIKit"])
    ],
    swiftLanguageVersions: [.v5]
)
