
import UIKit

/// This is a `UICollectionViewDiffableDataSource` that adds a
/// simple way to Pull to Refresh and empty views.
@available(iOS 14.0, *)
open class CollectionViewDiffableDataSource<Section: Hashable, Item: Hashable>:
    UICollectionViewDiffableDataSource<Section, Item>  {
    
    public weak var collectionView: UICollectionView!
    private var offsetObserver: NSKeyValueObservation?
    private var emptyView: UIView?
    
    public override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider) {
        super.init(collectionView: collectionView) { (cv, indexPath, item) -> UICollectionViewCell? in
            return cellProvider(cv, indexPath, item)
        }
        self.collectionView = collectionView
    }

    public var emptyConfiguration: ErrorView.Configuration? {
        didSet {
            collectionView.reloadData()
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

@available(iOS 14, *)
extension CollectionViewDiffableDataSource {
    
    public struct PullToRefreshProvider {
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
    
    func handlePullToRefresh() {
        /// This is here to fix a glitch when the refreshControl ends refreshing and the collectionView animates the new contents
        guard let provider = self.pullToRefreshProvider else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            provider.fetchHandler { [weak self] handler in
                guard let self = self else { return }
                var snapshot = self.snapshot()
                handler(&snapshot)
                self.apply(snapshot, animatingDifferences: true, completion: {
                    self.collectionView.refreshControl?.endRefreshing()
                })
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
