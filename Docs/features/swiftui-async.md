# SwiftUI Async Components

This area contains SwiftUI primitives for async loading, actions, paging and lightweight data-source coordination.

## AsyncView

`AsyncView` represents an async data load with idle, loading, loaded and error phases. It runs the `dataGenerator` from a `.task` when the view appears or its ID changes, then renders the hosted, loading or error view.

When the hosted view conforms to `PlaceholderDataProvider`, convenience initializers can render redacted placeholder content while loading.

## AsyncButton

`AsyncButton` wraps an `async throws` action and manages loading state, error alert presentation, optional HUD display and operation tracing.

Loading behavior is configured through `AsyncButtonLoadingConfiguration` and related environment helpers:

- Inline progress overlay.
- Blocking HUD with optional success message.
- Custom progress view provider.

## Infinite Scrolling

`InfiniteScrollingDataSource`, `InfiniteVerticalScrollView` and `PagingHandler` coordinate paged loading for SwiftUI lists. `PagingHandler` owns item state, loading state and fetch results; views consume this state to request more content as the user scrolls.

## Operation Tracing

`AsyncOperationTracer` records begin/end/error lifecycle information for async operations. This is useful when diagnosing slow or failing async UI flows.
