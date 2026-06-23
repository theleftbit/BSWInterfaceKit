# Objective-C Compatibility

`Sources/BSWInterfaceKitObjC/` keeps compatibility shims for older UIKit code and Objective-C-exposed APIs.

## Components

- `BSWCollectionViewLeftAlignedLayout` provides a left-aligned collection view layout.
- `BSWZoomTransition` and `BSWZoomImageTransition` implement zoom-style transitions.
- `UIView+Utilities` and `UIViewController+Utilities` expose layout and controller helpers to Objective-C consumers.
- Headers under `Sources/BSWInterfaceKitObjC/include/` define the public Objective-C surface.

## Maintenance Rule

Changes here can affect Swift and Objective-C consumers. Preserve exported symbol names and headers unless a breaking change is intentional and documented.
