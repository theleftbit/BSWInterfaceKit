#if canImport(UIKit.UICollectionView)

import UIKit
import BSWFoundation

/// This `UICollectionViewDiffableDataSource` subclass adds a
/// simple way to handle Pull to Refresh and empty views.
open class CollectionViewDiffableDataSource<Section: Hashable & Sendable, Item: Hashable & Sendable>:
    UICollectionViewDiffableDataSource<Section, Item>  {
    
    /// This type describes what to do when the `dataSource` is empty.
    @MainActor
    public enum EmptyConfiguration {
        /// Displays the given `UIView`
        case view(UIView)
        /// Displays the view described in `ErrorView.Configuration`
        case configuration(ErrorView.Configuration)
        /// Does nothing.
        case none
        
        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: UIButton.Configuration? = nil, handler: VoidHandler?) {
            self = .configuration(.init(title: title, message: message, image: image, buttonConfiguration: buttonConfiguration, handler: handler))
        }
        
        public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, button: UIButton? = nil) {
            self = .configuration(.init(title: title, message: message, image: image, button: button))
        }
    }
    
    public weak var collectionView: UICollectionView!
    private var offsetObserver: NSKeyValueObservation?
    private var emptyView: UIView?
    
    /// Initializes a `CollectionViewDiffableDataSource` with a given `collectionView` and a `cellProvider`
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
        MainActor.assumeIsolated {
            emptyView.removeFromSuperview()
        }
    }
        
    /// Specifies what to do when the `dataSource` is empty.
    public var emptyConfiguration: EmptyConfiguration = .none {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// Specifies how a Pull to Refresh will be handled.
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

    @available(iOS, deprecated: 15, obsoleted: 16, message: "Do not use this one")
    open override func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    /// The Swift 6 compiler is finding a data race issue here, which seems to be alliviated when doing this dance here.
    /// Very, very strange.  https://i.imgur.com/qjEYzTA.jpeg
#if swift(>=6.0)
    open override func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, animatingDifferences: Bool = true) async {
        let _: () = await withCheckedContinuation { cont in
            super.apply(snapshot, animatingDifferences: animatingDifferences) {
                cont.resume()
            }
        }
    }
    
    open override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>) async {
        let _: () = await withCheckedContinuation { cont in
            super.applySnapshotUsingReloadData(snapshot) {
                cont.resume()
            }
        }
    }
#endif
    
    // MARK: Actions
    
    @objc private func _handlePullToRefresh() {
        handlePullToRefresh()
    }
}

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
            await self.apply(snapshot, animatingDifferences: true)
            self.collectionView.refreshControl?.endRefreshing()
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
