#if canImport(UIKit)

import UIKit

/**
 This is a `CollectionViewDiffableDataSource`
 that adds a simple way to support for infiniteScroll.
 ```
 dataSource.infiniteScrollProvider = .init(fetchHandler: { completion in
    completion({ snapshot in
        snapshot.appendItems([.foo, .bar], toSection: .main)
        return true
    })
 })
  ```
 */
@available(iOS 14.0, *)
open class PagingCollectionViewDiffableDataSource<Section: Hashable, Item: PagingCollectionViewItem>:
    CollectionViewDiffableDataSource<Section, Item> {
        
    private var offsetObserver: NSKeyValueObservation?
    public let scrollDirection: UICollectionView.ScrollDirection
    fileprivate var isRequestingNextPage: Bool = false

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

@available(iOS 14, *)
public extension PagingCollectionViewDiffableDataSource {
    struct InfiniteScrollProvider {
        /// Sends the user a snapshot to perform the changes and
        /// the user must return a Bool indicating if more pages are available
        public typealias ResultHandler = ((inout NSDiffableDataSourceSnapshot<Section, Item>) -> (Bool))
        public typealias FetchHandler = (@escaping (ResultHandler) -> ()) -> ()

        public let fetchHandler: FetchHandler
        
        public init(fetchHandler: @escaping FetchHandler) {
            self.fetchHandler = fetchHandler
        }
    }
}

@available(iOS 14, *)
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
        
        isRequestingNextPage = true
        /// Start paging
        var startPagingSnapshot = self.snapshot()
        PagingCollectionViewDiffableDataSource
            .startPaginating(snapshot: &startPagingSnapshot)
        self.apply(startPagingSnapshot, animatingDifferences: true) {

            infiniteScrollSupport.fetchHandler { [weak self] handler in
                guard let self = self else { return }
                var finishPagingSnapshot = self.snapshot()
                let morePagesAvailable = handler(&finishPagingSnapshot)
                PagingCollectionViewDiffableDataSource
                    .stopPaginating(snapshot: &finishPagingSnapshot)
                self.apply(finishPagingSnapshot, animatingDifferences: true) {
                    if !morePagesAvailable {
                        self.infiniteScrollProvider = nil
                    }
                    self.isRequestingNextPage = false
                }
            }
        }
    }
}
#endif
