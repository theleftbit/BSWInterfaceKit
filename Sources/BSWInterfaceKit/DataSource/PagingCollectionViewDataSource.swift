#if canImport(UIKit)

import UIKit

/**
 This is a `CollectionViewDiffableDataSource`
 that adds a simple way to support for infiniteScroll.
 ```
 dataSource.infiniteScrollProvider = .init(fetchHandler: { snapshot in
     let items = try await fetchTheItems()
     snapshot.appendItems(items, toSection: .main)
     return true
 })
  ```
 */
open class PagingCollectionViewDiffableDataSource<Section: Hashable, Item: PagingCollectionViewItem>:
    CollectionViewDiffableDataSource<Section, Item> {
        
    private var offsetObserver: NSKeyValueObservation?
    public let scrollDirection: UICollectionView.ScrollDirection
    public var currentFetch: Task<Bool, Never>?
    private var isRequestingNextPage: Bool {
        currentFetch != nil
    }
    
    public init(collectionView: UICollectionView, scrollDirection: UICollectionView.ScrollDirection = .vertical, cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider) {
        self.scrollDirection = scrollDirection
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }
    
    public var infiniteScrollProvider: InfiniteScrollProvider? {
        didSet {
            prepareForInfiniteScroll()
        }
    }
}

/// Represents an Item that can be represented on a
/// `PagingCollectionViewDiffableDataSource`
/// forcing that Item to accomodate a `loading` option,
/// which will be displayed during paging
public protocol PagingCollectionViewItem: Hashable {
    var isLoading: Bool { get }
    static func loadingItem() -> Self
}

public extension PagingCollectionViewDiffableDataSource {
    struct InfiniteScrollProvider {
        /// Sends the user a snapshot to perform the changes and
        /// the user must return a Bool indicating if more pages are available
        public typealias FetchHandler = ((inout NSDiffableDataSourceSnapshot<Section, Item>) async -> (Bool))

        public let fetchHandler: FetchHandler
        
        public init(fetchHandler: @escaping FetchHandler) {
            self.fetchHandler = fetchHandler
        }
    }
}

private extension PagingCollectionViewDiffableDataSource {
    func prepareForInfiniteScroll() {
        guard let _ = self.infiniteScrollProvider else {
            offsetObserver = nil
            return
        }
        
        offsetObserver = self.collectionView.observe(\.contentOffset, changeHandler: { [weak self] (cv, change) in
            guard let self = self else { return }
            switch self.scrollDirection {
            case .vertical:
                let offsetY = cv.contentOffset.y
                let contentHeight = cv.contentSize.height
                guard offsetY > 0, contentHeight > 0 else { return }
                if offsetY > contentHeight - cv.frame.size.height {
                    self.requestNextInfiniteScrollPage()
                }
            case .horizontal:
                let offsetX = cv.contentOffset.x
                let contentWidth = cv.contentSize.width
                guard offsetX > 0, contentWidth > 0 else { return }
                if offsetX > contentWidth - cv.frame.size.width {
                    self.requestNextInfiniteScrollPage()
                }
            @unknown default:
                fatalError()
            }
        })
    }
    
    static func startPaginating(snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
        guard let lastSection = snapshot.sectionIdentifiers.last else {
            return
        }
        snapshot.appendItems([Item.loadingItem()], toSection: lastSection)
    }
    
    static func stopPaginating(snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
        snapshot.deleteItems([Item.loadingItem()])
    }
    
    func requestNextInfiniteScrollPage() {
        guard !isRequestingNextPage, let infiniteScrollSupport = self.infiniteScrollProvider else { return }

        Task { @MainActor in
            print("Animation snapshot")
            var startPagingSnapshot = self.snapshot()
            PagingCollectionViewDiffableDataSource
                .startPaginating(snapshot: &startPagingSnapshot)
            await apply(startPagingSnapshot, animatingDifferences: true)

            let morePagesAvailable = (await self.currentFetch?.value) ?? true

            if !morePagesAvailable {
                self.infiniteScrollProvider = nil
            }
            self.currentFetch = nil
        }
        
        self.currentFetch = Task { @MainActor in
            print("Changes snapshot")
            var changesSnapshot = self.snapshot()
            let morePagesAvailable = await infiniteScrollSupport.fetchHandler(&changesSnapshot)
            PagingCollectionViewDiffableDataSource
                .stopPaginating(snapshot: &changesSnapshot)
            await self.apply(changesSnapshot, animatingDifferences: true)
            return morePagesAvailable
        }
    }
}
#endif
