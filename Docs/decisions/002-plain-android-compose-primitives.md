# 002 - Plain Android Compose Primitives

Date: 2026-06-23

## Status

Accepted

## Context

Skip apps need Android equivalents for shared async UI patterns, navigation, sheets and view-model retention. These primitives must be reusable across products with different styling and copy.

## Decision

Android-only Compose APIs under `Sources/BSWInterfaceKit/Skip/` stay plain and infrastructure-focused. They use the `BSW` prefix and are intended to be wrapped by product apps for localized strings, branded visuals and feature-specific defaults.

## Consequences

- Shared Android APIs should avoid product-specific copy and styling.
- Lifecycle and Swift view-model retention behavior belongs in this package.
- App-level wrappers own visual polish, localization and domain-specific behavior.
