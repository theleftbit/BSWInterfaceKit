// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.4"),
        .package(url: "https://github.com/theleftbit/BSWFoundation.git", from: "6.2.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeExtensions", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                "BSWInterfaceKitObjC",
                "BSWFoundation"
            ]
        ),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: ["BSWInterfaceKit", .product(name: "SnapshotTesting", package: "swift-snapshot-testing")],
            exclude: ["Suite/__Snapshots__/"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
