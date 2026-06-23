# SwiftUI Modifiers And State Surfaces

SwiftUI modifiers provide reusable interaction surfaces around async work, transient status and layout behavior.

## HUD

`hud(hudState:configuration:)` presents loading and success states through `HUDState` and `HUDConfiguration`.

The implementation branches by platform:

- iOS uses an iOS-specific HUD modifier.
- Android uses the Compose-backed modifier.
- macOS uses a macOS-specific modifier.

## Blocking Tasks

`performBlockingTask(...)` runs async work from a binding trigger and can require confirmation before execution. It displays loading, success and error states through the HUD/error alert machinery.

## Other Modifiers

- `actionBar(...)` provides a reusable SwiftUI bottom/action-bar surface.
- `intrinsicHeightSheet(...)` helps sheet presentation size to content.
- `shimmer(...)` provides redacted loading motion.
- In-app notification modifiers bridge event-style notification display into SwiftUI.

## State Ownership

Modifiers that run async tasks should keep view state local and avoid leaking feature-specific strings or styling into this package. Product apps should wrap them when they need localized copy or branded presentation.
