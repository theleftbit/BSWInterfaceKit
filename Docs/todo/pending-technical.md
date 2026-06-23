# Technical Pending

Last updated: 2026-06-23.

## Open Items

- Decide whether Mac Catalyst, tvOS and visionOS should be declared as package platforms or only kept in dependency conditions.
- Keep README Android support notes aligned with `Sources/BSWInterfaceKit/Skip/`.
- Add focused DocC examples for `AsyncView`, `AsyncButton`, `performBlockingTask`, `CollectionViewDiffableDataSource`, `MediaPickerBehavior` and `BSWSheet`.
- Add focused DocC examples for `PhotoView`, `JSONTreeView`, `RootViewController`, `BottomContainerViewController` and `UpdatePageControlOnScrollBehavior`.
- Review which UIKit APIs are intended to support macOS, Mac Catalyst, tvOS or watchOS and document intentional exclusions.
- Keep snapshot expectations updated when shared visual behavior changes intentionally.
- Periodically check that Android Compose primitives stay plain infrastructure rather than accumulating product-specific copy or branding.

## Maintenance Triggers

Update this list when adding public UI APIs, changing platform support, altering async loading/error behavior, changing view-model lifetime, modifying navigation/sheet behavior or updating shared visual state components.
