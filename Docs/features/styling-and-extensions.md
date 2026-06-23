# Styling And Extensions

`BSWInterfaceKit` exposes a broad set of UIKit, SwiftUI and text utilities. These APIs are easy for downstream apps to depend on, so keep behavior changes conservative.

## Styling

`TextStyler` centralizes attributed text styling and is covered by snapshot tests. `NSAttributedString` helpers cover concatenation, paragraph spacing, links, bolding and attribute application.

Color and font helpers extend UIKit/AppKit/SwiftUI types where available. `LocalizationService` and the `String.localized` helper provide package-level localization lookup for shared UI strings.

## UIKit Extensions

Common extension areas include:

- View layout helpers such as pinning, centering and nib instantiation.
- View controller presentation, containment, error/loading states and async fetch helpers.
- Button, label, text field, image, image view, collection view, table view, content view and stack view utilities.
- Keyboard layout guide helpers.
- `UIScreen`, `UIWindow`, `UIResponder`, `UIEdgeInsets` and `UIActivityIndicatorView.Style` compatibility helpers.
- `isiOSAppOnMac()` for detecting iOS apps running on macOS.

## Models And Protocols

`Photo` models local/remote/empty image state and random colors. `ViewModelConfigurable`, `ViewModelReusable` and `IntrinsicSizeCalculable` support reusable UIKit views and cells.
