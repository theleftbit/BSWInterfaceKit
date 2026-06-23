# BSWInterfaceKit Knowledge Base

Last updated: 2026-06-23.

This directory is the source of package context for `BSWInterfaceKit`: shared UIKit and SwiftUI components, Android Skip Compose primitives, Objective-C compatibility shims, view/controller helpers, data sources, presentation utilities and pending technical work.

## Quick Start

- [Project overview](context/project-overview.md)
- [Module map](context/module-map.md)
- [Platform support](context/platform-support.md)
- [SwiftUI async components](features/swiftui-async.md)
- [SwiftUI modifiers and state surfaces](features/swiftui-modifiers.md)
- [UIKit views and controllers](features/uikit-views-and-controllers.md)
- [Data sources and collection layouts](features/data-sources-and-layouts.md)
- [Media, social and in-app integrations](features/media-social-integrations.md)
- [Android Skip components](features/android-skip.md)
- [Styling and extensions](features/styling-and-extensions.md)
- [Objective-C compatibility](features/objective-c-compatibility.md)
- [Technical pending](todo/pending-technical.md)

## Decisions

- [001 - Shared UI foundation package](decisions/001-shared-ui-foundation-package.md)
- [002 - Plain Android Compose primitives](decisions/002-plain-android-compose-primitives.md)

## Systems

- Package: `BSWInterfaceKit`
- Package manifest: `Package.swift`
- Runtime source: `Sources/BSWInterfaceKit/`
- Objective-C shim target: `Sources/BSWInterfaceKitObjC/`
- Android Skip source: `Sources/BSWInterfaceKit/Skip/`
- Tests and snapshots: `Tests/BSWInterfaceKitTests/`
- Public API docs: Swift Package Index DocC documentation
