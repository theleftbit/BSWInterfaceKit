# UIKit Views And Controllers

UIKit code provides reusable UI building blocks for app screens that are not pure SwiftUI.

## Views

Common view types include:

- `AvatarView` for circular user images backed by `Photo`.
- `ErrorView` and `LoadingView` for reusable state surfaces.
- `RangeSlider`, `CheckboxButton`, `SeparatorView`, `RoundLayer` and `LinkAwareLabel`.
- `PhotoGalleryView` and `PhotoGalleryViewController` for image galleries.
- `ScrollableStackView` for stack-based scrolling layouts.

## Controllers

`ContainerViewController` and `RootViewController` simplify swapping child controllers while forwarding status-bar and home-indicator behavior.

`BottomContainerViewController` and presentation helpers provide reusable bottom/card presentation patterns.

`TextFieldAlertController` wraps a text-input alert flow.

## State Views

`UIViewController+States` provides loading/error/success state handling for UIKit controllers. Keep behavior changes documented because downstream apps may rely on these state transitions and layouts.
