
import UIKit

/// TODO:
/// - Pull to refresh ☑️
/// - Paging ☑️
/// - Empty View ☑️
/// - Horizontal Scroll
/// Reorder and SupplementaryView are handled by `UICollectionViewDiffableDataSource`
@available(iOS 14.0, *)
public class CollectionViewDiffableDataSource<Section: Hashable, Item: CollectionViewDiffableItemWithLoading>:
    UICollectionViewDiffableDataSource<Section, Item> {
    
    private weak var collectionView: UICollectionView!
    private var offsetObserver: NSKeyValueObservation?
    private var emptyView: UIView?

    public override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider) {
        super.init(collectionView: collectionView) { (cv, indexPath, item) -> UICollectionViewCell? in
            if item.isLoading {
                let loadingRegistration = UICollectionView.CellRegistration<LoadingCell, Item> { (cell, _, _) in
                    cell.accessories = []
                    cell.loadingView.startAnimating()
                }
                return cv.dequeueConfiguredReusableCell(using: loadingRegistration, for: indexPath, item: item)
            } else {
                return cellProvider(cv, indexPath, item)
            }
        }
        self.collectionView = collectionView
    }

    public var emptyConfiguration: ErrorView.Configuration? {
        didSet {
            collectionView.reloadData()
        }
    }

    public var infiniteScrollProvider: InfiniteScrollProvider? {
        didSet {
            prepareForInfiniteScroll()
        }
    }
    
    public var pullToRefreshProvider: PullToRefreshProvider? {
        didSet {
            prepareForPullToRefresh()
        }
    }
    
    /// MARK: Overrides
    /*
     This overrides are here just to add the empty view
     */
    @objc public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        defer { addEmptyView() }
        return super.numberOfSections(in: collectionView)
    }

    @objc public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        defer { addEmptyView() }
        return super.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    
    // MARK: Actions
    
    @objc private func _handlePullToRefresh() {
        handlePullToRefresh()
    }
}

public protocol CollectionViewDiffableItemWithLoading: Hashable {
    var isLoading: Bool { get }
    static func loadingItem() -> Self
}

@available(iOS 14, *)
public extension CollectionViewDiffableDataSource {
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
    
    struct PullToRefreshProvider {
        public typealias ResultHandler = ((inout NSDiffableDataSourceSnapshot<Section, Item>) -> ())
        public typealias FetchHandler = (@escaping (ResultHandler) -> ()) -> ()
        public let fetchHandler: FetchHandler
        public let tintColor: UIColor?
        
        public init(tintColor: UIColor? = nil, fetchHandler: @escaping FetchHandler) {
            self.tintColor = tintColor
            self.fetchHandler = fetchHandler
        }
    }
}


@available(iOS 14, *)
private extension CollectionViewDiffableDataSource {
    func addEmptyView() {
        
        guard let emptyConfiguration = self.emptyConfiguration else {
            return
        }
        
        self.emptyView?.removeFromSuperview()
        
        let currentSnapshot = self.snapshot()
        if currentSnapshot.sectionIdentifiers.count == 0 || currentSnapshot.itemIdentifiers.count == 0 {
            emptyView = emptyConfiguration.viewRepresentation()
        } else {
            emptyView = nil
        }
        
        guard let emptyView = self.emptyView, let collectionView = self.collectionView else { return }
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        let superView: UIView = {
            if let hostView = collectionView.superview {
                hostView.insertSubview(emptyView, aboveSubview: collectionView)
                return hostView
            } else {
                collectionView.addSubview(emptyView)
                return collectionView
            }
        }()
        
        let spacing: CGFloat = 20
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
            emptyView.leadingAnchor.constraint(greaterThanOrEqualTo: superView.leadingAnchor, constant: spacing),
            emptyView.trailingAnchor.constraint(greaterThanOrEqualTo: superView.trailingAnchor, constant: -spacing)
        ])
    }
}

@available(iOS 14, *)
private extension CollectionViewDiffableDataSource {
    
    func prepareForInfiniteScroll() {
        guard let _ = self.infiniteScrollProvider else {
            offsetObserver = nil
            return
        }
    
        offsetObserver = self.collectionView.observe(\.contentOffset, changeHandler: { [weak self] (cv, change) in
            guard let self = self else { return }
            let offsetY = cv.contentOffset.y
            let contentHeight = cv.contentSize.height
            guard offsetY > 0, contentHeight > 0 else { return }
            if offsetY > contentHeight - cv.frame.size.height {
                self.requestNextInfiniteScrollPage()
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

    class LoadingCell: UICollectionViewListCell {

        let Margins: UIEdgeInsets = .init(uniform: 8)
        let loadingView = UIActivityIndicatorView(style: .defaultStyle)

        public override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundConfiguration = .clear()
            contentView.addAutolayoutSubview(loadingView)
            let heightAnchor = loadingView.heightAnchor.constraint(equalToConstant: 16)
            heightAnchor.priority = .init(999)
            NSLayoutConstraint.activate([
                heightAnchor,
                loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor),
                loadingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.top),
                contentView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.bottom),
            ])
        }

        public required init?(coder: NSCoder) {
            fatalError("not implemented")
        }
    }
}

//MARK: PullToRefreshProvider

@available(iOS 14, *)
private extension CollectionViewDiffableDataSource {
    
    func handlePullToRefresh() {
        guard let provider = self.pullToRefreshProvider else { return }
        provider.fetchHandler { [weak self] handler in
            guard let self = self else { return }
            var snapshot = self.snapshot()
            handler(&snapshot)
            self.collectionView.refreshControl?.endRefreshing()
            /// This is here to fix a glitch when the refreshControl ends refreshing and the collectionView animates the new contents
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    func prepareForPullToRefresh() {
        guard let provider = self.pullToRefreshProvider else {
            self.collectionView.refreshControl = nil
            return
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = provider.tintColor
        refreshControl.addTarget(self, action: #selector(_handlePullToRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
}
