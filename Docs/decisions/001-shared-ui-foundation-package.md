# 001 - Shared UI Foundation Package

Date: 2026-06-23

## Status

Accepted

## Context

TheLeftBit apps need reusable UI infrastructure for common loading, error, media, presentation, data-source and styling patterns. Duplicating this behavior in apps increases inconsistency and makes cross-app fixes slower.

## Decision

`BSWInterfaceKit` remains a Swift Package Manager library that exports one product, `BSWInterfaceKit`, composed of the Swift target and the Objective-C shim target.

Package-level context lives in `Docs/`; symbol-level reference remains in DocC comments and Swift Package Index.

## Consequences

- Public UI behavior changes should be treated as shared-library changes.
- Snapshot-tested components should preserve visual behavior unless the visual change is intentional.
- Product-specific strings, branding and feature policy should usually live in app wrappers, not in this package.
