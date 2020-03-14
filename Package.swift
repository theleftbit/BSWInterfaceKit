// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
        .library(
            name: "BSWSnapshotTest",
            targets: ["BSWSnapshotTest"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .exact("1.7.2")),
        .package(url: "https://github.com/bignerdranch/Deferred.git", from: "4.1.0"),
        .package(url: "https://github.com/theleftbit/BSWFoundation.git", from: "3.2.0"),
        .package(url: "https://github.com/kean/Nuke.git", from: "8.3.0"),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: ["Nuke", "BSWInterfaceKitObjC", "Deferred", "BSWFoundation"]
        ),
        .target(name: "BSWSnapshotTest", dependencies: ["SnapshotTesting", "BSWInterfaceKit"]),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: ["BSWSnapshotTest"]
        ),
    ]
)
