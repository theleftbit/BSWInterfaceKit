# Module Map

## SwiftUI

`Sources/BSWInterfaceKit/SwiftUI/` contains async state views, infinite scrolling, photo rendering, JSON tree display, HUD/blocking task/action bar modifiers, view builders, popover helpers, placeholder protocols and operation tracing.

Important public surfaces include:

- `AsyncView`
- `AsyncButton`
- `InfiniteVerticalScrollView`
- `InfiniteScrollingDataSource`
- `PagingHandler`
- `PhotoView`
- `JSONTreeView`
- `HUDState` and `HUDConfiguration`
- `performBlockingTask(...)`
- `AsyncOperationTracer`

## UIKit

UIKit source covers reusable views, cells, view controllers, behaviors, extensions, presentations and data sources.

Important areas include:

- `AvatarView`, `ErrorView`, `LoadingView`, `RangeSlider`, `CheckboxButton`, `SeparatorView`, `LinkAwareLabel` and `ScrollableStackView`.
- `ContainerViewController`, `RootViewController`, `BottomContainerViewController`, `PhotoGalleryViewController` and `TextFieldAlertController`.
- `CollectionViewDiffableDataSource`, `PagingCollectionViewDiffableDataSource` and `SelectableTableViewDataSource`.
- `CardPresentation` and `MarqueePresentation`.
- `MediaPickerBehavior`, `MessageComposerBehavior`, `UpdatePageControlOnScrollBehavior` and UIKit in-app notification helpers.

## Android Skip

`Sources/BSWInterfaceKit/Skip/` contains Android-only Compose primitives such as `BSWAsyncView`, `BSWAsyncButton`, `BSWSheet`, `BSWNavDisplay`, `BSWBackButton`, blocking task/HUD helpers and Swift view-model retention utilities.

## Objective-C Compatibility

`Sources/BSWInterfaceKitObjC/` exposes Objective-C-compatible layout, transition and utility shims used by older UIKit code:

- `BSWCollectionViewLeftAlignedLayout`
- `BSWZoomTransition`
- `BSWZoomImageTransition`
- `UIView+Utilities`
- `UIViewController+Utilities`

## Integrations

The package includes media picking, mail/message composer helpers, social authentication, in-app notifications and Nuke-backed image utilities.
