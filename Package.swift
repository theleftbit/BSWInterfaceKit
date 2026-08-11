// swift-tools-version:6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let skipIsEnabled = (ProcessInfo.processInfo.environment["SKIP_ENABLED"] != nil)

let applePlatforms = TargetDependencyCondition.when(
    platforms: [
        .iOS,
        .macOS,
        .macCatalyst,
        .tvOS,
        .watchOS,
        .visionOS
    ]
)

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.19.3"),
    .package(url: "https://github.com/theleftbit/BSWFoundation.git", from: "8.0.0"),
    .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
]

if skipIsEnabled {
    packageDependencies.append(contentsOf: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.4"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.18.0"),
    ])
}

var targetDependencies: [Target.Dependency] = [
    .product(name: "Nuke", package: "Nuke", condition: applePlatforms),
    .product(name: "NukeExtensions", package: "Nuke", condition: applePlatforms),
    .product(name: "NukeUI", package: "Nuke", condition: applePlatforms),
    "BSWInterfaceKitObjC",
    "BSWFoundation"
]

if skipIsEnabled {
    targetDependencies.append(contentsOf: [
        .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
    ])
}

var plugins: [Target.PluginUsage] = [ ]
if skipIsEnabled {
    plugins.append(
        .plugin(name: "skipstone", package: "skip")
    )
}

let package = Package(
    name: "BSWInterfaceKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "BSWInterfaceKit",
            targets: ["BSWInterfaceKit", "BSWInterfaceKitObjC"]
        ),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(name: "BSWInterfaceKitObjC"),
        .target(
            name: "BSWInterfaceKit",
            dependencies: targetDependencies,
            plugins: plugins
        ),
        .testTarget(
            name: "BSWInterfaceKitTests",
            dependencies: [
                "BSWInterfaceKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["Suite/__Snapshots__/"]
        ),
    ]
)
