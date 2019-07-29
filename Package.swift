// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            type: .dynamic,
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bignerdranch/Deferred.git", from: "4.0.0"),
        .package(url: "https://github.com/theleftbit/BSWFoundation.git", .branch("xcode11")),
        .package(url: "https://github.com/kean/Nuke.git", .revision("8.0-rc.1")),
    ],
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: ["Nuke", "BSWInterfaceKitObjC", "Deferred", "BSWFoundation"]),
    ]
)
