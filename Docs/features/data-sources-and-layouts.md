# Data Sources And Layouts

This package includes reusable data-source and layout helpers for UIKit collection and table views.

## CollectionViewDiffableDataSource

`CollectionViewDiffableDataSource` subclasses `UICollectionViewDiffableDataSource` and adds:

- Empty view handling through `EmptyConfiguration`.
- Pull-to-refresh support through `PullToRefreshProvider`.
- Snapshot reconfiguration after async refresh.

## Paging Collection Data Source

`PagingCollectionViewDiffableDataSource` adds paging semantics for items conforming to `PagingCollectionViewItem`.

## Selectable Table View Data Source

`SelectableTableViewDataSource` coordinates selectable table cells that conform to `ViewModelReusable`.

## Layouts

`HorizontalPagedCollectionViewLayout` supports horizontally paged collection views with configurable item sizing and alignment.

`BSWCollectionViewLeftAlignedLayout` lives in the Objective-C shim target for legacy left-aligned collection layouts.
