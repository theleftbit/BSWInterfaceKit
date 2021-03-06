
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
    
    func startPaginating() {
        var snapshot = self.snapshot()
        guard let lastSection = snapshot.sectionIdentifiers.last else {
            return
        }
        snapshot.appendItems([Item.loadingItem()], toSection: lastSection)
        self.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func stopPaginating() {
        var snapshot = self.snapshot()
        snapshot.deleteItems([Item.loadingItem()])
        self.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    var isRequestingNextPage: Bool {
        self.snapshot().sectionIdentifier(containingItem: Item.loadingItem()) != nil
    }

    func requestNextInfiniteScrollPage() {
        guard !isRequestingNextPage, let infiniteScrollSupport = self.infiniteScrollProvider else { return }
        startPaginating()
        infiniteScrollSupport.fetchHandler { [weak self] handler in
            guard let self = self else { return }
            self.stopPaginating()
            var snapshot = self.snapshot()
            let shouldStopPaging = handler(&snapshot)
            self.apply(snapshot, animatingDifferences: true, completion: nil)
            if !shouldStopPaging {
                self.infiniteScrollProvider = nil
            }
        }
    }
}
