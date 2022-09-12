// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
        
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.2"),
        .package(name: "BSWFoundation", url: "https://github.com/theleftbit/BSWFoundation.git", from: "5.1.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "11.2.1"),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: [
                "Nuke",
                .product(name: "NukeUI", package: "Nuke"),
                "BSWInterfaceKitObjC",
                "BSWFoundation"
            ]
        ),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: ["BSWInterfaceKit", "SnapshotTesting"],
            exclude: ["Suite/__Snapshots__/"]
        ),
    ]
)
