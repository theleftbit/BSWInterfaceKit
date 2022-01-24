// swift-tools-version:5.5
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
            type: .dynamic,
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.2"),
        .package(name: "Deferred", url: "https://github.com/theleftbit/Deferred.git", from: "4.2.0"),
        .package(name: "BSWFoundation", url: "https://github.com/theleftbit/BSWFoundation.git", from: "5.0.0"),
        .package(name: "Nuke", url: "https://github.com/kean/Nuke.git", from: "10.5.2"),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: ["Nuke", "BSWInterfaceKitObjC", "Deferred", "BSWFoundation"]
        ),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: ["BSWInterfaceKit", "SnapshotTesting"],
            exclude: ["Suite/__Snapshots__/"]
        ),
    ]
)
