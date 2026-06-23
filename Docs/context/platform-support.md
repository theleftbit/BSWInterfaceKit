# Platform Support

`BSWInterfaceKit` is Apple UI-first and has an explicit Skip/Android path for selected SwiftUI-equivalent infrastructure.

## Apple Platforms

The package declares iOS, macOS and watchOS support in `Package.swift`. Many UIKit APIs are guarded with `canImport(UIKit...)`, `os(iOS)` or availability checks, so support varies by symbol.

Apple-specific areas include:

- UIKit views, view controllers, cells, collection/table data sources and presentation controllers.
- Media picking and thumbnail generation, guarded by Photos, UIKit and related frameworks.
- Social authentication, currently iOS-only.
- Objective-C shim target used by UIKit code.
- Nuke image-loading dependencies, included only for Apple platforms through dependency conditions.

The dependency condition also includes Mac Catalyst, tvOS and visionOS for Apple-only dependencies, but those platforms are not currently declared as minimum package platforms.

## Android Via Skip

When `SKIP_ENABLED` is present, the package adds Skip dependencies and the Skip plugin:

- `skip`
- `skip-fuse-ui`
- `SkipFuseUI`
- `skipstone` plugin

Android-only source lives under `Sources/BSWInterfaceKit/Skip/` and is intentionally implemented as plain Compose infrastructure. Product apps should wrap these primitives to apply strings, branding, styling and feature-specific defaults.

## Compatibility Rule

New shared SwiftUI-style APIs should decide explicitly whether they need Android parity. UIKit/AppKit-only APIs must remain guarded. Android Compose APIs should keep the `BSW` prefix used in the README to avoid collisions with Skip-generated SwiftUI symbols.
