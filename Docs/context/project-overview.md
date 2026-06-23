# Project Overview

`BSWInterfaceKit` is a Swift Package Manager library containing shared user-interface infrastructure for TheLeftBit apps. It combines UIKit components, SwiftUI views and modifiers, image/media helpers, social authentication helpers, snapshot-tested UI utilities and Android-only Compose primitives used by Skip builds.

## Package Shape

- Product: `BSWInterfaceKit`
- Swift target: `Sources/BSWInterfaceKit`
- Objective-C target: `Sources/BSWInterfaceKitObjC`
- Test target: `Tests/BSWInterfaceKitTests`
- Swift tools version: `6.2`
- Minimum declared platforms: iOS 17, macOS 15 and watchOS 11

## Dependencies

- `BSWFoundation` provides shared foundation helpers and aliases.
- `Nuke`, `NukeExtensions` and `NukeUI` power image loading on Apple platforms.
- `swift-snapshot-testing` is used by the test target.
- `skip` and `skip-fuse-ui` are included only when `SKIP_ENABLED` is present.

## Documentation Responsibilities

Use `Docs/` for package-level context: why components exist, which platform boundaries matter, how public UI behavior should be consumed and what maintenance work remains. Keep DocC comments as the source for symbol-level API details.
