// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bignerdranch/Deferred.git", from: "4.1.0"),
        .package(url: "https://github.com/theleftbit/BSWFoundation.git", from: "3.1.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "8.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.6.0"),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: ["Nuke", "BSWInterfaceKitObjC", "Deferred", "BSWFoundation"]
        ),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: ["BSWInterfaceKit", "SnapshotTesting"]
        ),
    ]
)
