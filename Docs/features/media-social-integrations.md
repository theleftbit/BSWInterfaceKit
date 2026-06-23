# Media, Social And In-App Integrations

This package includes app-integration helpers that sit close to UIKit and platform frameworks.

## Media Picker

`MediaPickerBehavior` presents photo library, camera or files flows and returns a temporary file URL. It supports photo, video and thumbnail requests and can generate thumbnails from video assets.

Because it depends on Photos, UIKit, AVFoundation and related frameworks, it is Apple-only and unavailable on tvOS.

## Mail And Message Composer

`MessageComposerBehavior` wraps mail and message composer delegates to simplify presentation and completion handling.

## Social Authentication

`SocialAuthenticationManager` performs OAuth login through `ASWebAuthenticationSession`. Facebook support is implemented through `SocialAuthenticationManager.FacebookCredentials`.

This area is currently iOS-only.

## In-App Notifications

UIKit and SwiftUI in-app notification helpers provide reusable transient notification presentation. Keep copy and product-specific styling outside this package where possible.
