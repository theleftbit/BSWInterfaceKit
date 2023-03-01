#if canImport(UIKit)

import UIKit

/// This is a `UICollectionViewDiffableDataSource` that adds a
/// simple way to Pull to Refresh and empty views.
open class CollectionViewDiffableDataSource<Section: Hashable, Item: Hashable>:
    UICollectionViewDiffableDataSource<Section, Item>  {
    
    public enum EmptyConfiguration {
        case view(UIView)
        case configuration(ErrorView.Configuration)
        case none
        
        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, button: UIButton? = nil) {
            self = .configuration(.init(title: title, message: message, image: image, button: button))
        }
    }
    
    public weak var collectionView: UICollectionView!
    private var offsetObserver: NSKeyValueObservation?
    private var emptyView: UIView?
    
    public override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider) {
        super.init(collectionView: collectionView) { (cv, indexPath, item) -> UICollectionViewCell? in
            return cellProvider(cv, indexPath, item)
        }
        self.collectionView = collectionView
    }
    
    deinit {
        guard let emptyView = emptyView else {
            return
        }
        emptyView.removeFromSuperview()
    }

    public var emptyConfiguration: EmptyConfiguration = .none {
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
    
    @MainActor
    public override func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, animatingDifferences: Bool = true) async {
        await super.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    
    // MARK: Actions
    
    @objc private func _handlePullToRefresh() {
        handlePullToRefresh()
    }
}

@available(iOS 14, *)
extension CollectionViewDiffableDataSource {

    public struct PullToRefreshProvider {
        public typealias FetchHandler = ((inout NSDiffableDataSourceSnapshot<Section, Item>) async -> ())
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
        guard let provider = self.pullToRefreshProvider else { return }
        Task { @MainActor in
            /// This is here to fix a glitch when the refreshControl ends refreshing and the collectionView animates the new contents
            async let waitSleep: () = Task.sleep(nanoseconds: 300_000_000)
            var snapshot = self.snapshot()
            await provider.fetchHandler(&snapshot)
            snapshot.reconfigureItems(snapshot.itemIdentifiers)
            try? await waitSleep
            self.apply(snapshot, animatingDifferences: true, completion: {
                self.collectionView.refreshControl?.endRefreshing()
            })
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
        self.emptyView?.removeFromSuperview()
        let currentSnapshot = self.snapshot()
        let isListEmpty = currentSnapshot.sectionIdentifiers.isEmpty || currentSnapshot.itemIdentifiers.isEmpty
        guard let collectionView = self.collectionView,
              isListEmpty,
              let emptyView: UIView = {
                  switch emptyConfiguration {
                  case .none:
                      return nil
                  case .view(let view):
                      return view
                  case .configuration(let config):
                      return config.viewRepresentation()
                  }
              }()
        else { return }
        
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
        
        self.emptyView = emptyView
    }
}
#endif
