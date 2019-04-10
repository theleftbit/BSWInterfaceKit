//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public class CollectionViewDataSource<Cell:ViewModelReusable & UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    public private(set) var data: [Cell.VM]
    public weak var collectionView: UICollectionView!
    public var emptyConfiguration: ErrorView.Configuration?
    private var emptyView: UIView?
    private var offsetObserver: NSKeyValueObservation?
    private var isRequestingNextPage: Bool = false {
        didSet {
            if isRequestingNextPage {
                loadingCollectionViewCell?.activityIndicator.startAnimating()
            } else {
                loadingCollectionViewCell?.activityIndicator.stopAnimating()
            }
        }
    }
    private var loadingCollectionViewCell: InfiniteLoadingCollectionViewCell?
    
    public init(data: [Cell.VM] = [],
                collectionView: UICollectionView,
                emptyConfiguration: ErrorView.Configuration? = nil) {
        self.data = data
        self.collectionView = collectionView
        self.emptyConfiguration = emptyConfiguration

        super.init()

        collectionView.registerReusableCell(Cell.self)
        collectionView.dataSource = self
    }

    public var infiniteScrollSupport: CollectionViewInfiniteScrollSupport<Cell.VM>? {
        didSet {
            guard let _ = self.infiniteScrollSupport else {
                offsetObserver = nil
                return
            }
            collectionView.registerReusableCell(InfiniteLoadingCollectionViewCell.self)
            offsetObserver = self.collectionView.observe(\.contentOffset, changeHandler: { [weak self] (cv, change) in
                let offsetY = cv.contentOffset.y
                let contentHeight = cv.contentSize.height
                guard let `self` = self, offsetY > 0, contentHeight > 0 else { return }
                if offsetY > contentHeight - cv.frame.size.height {
                    self.requestNextInfiniteScrollPage()
                }
            })
        }
    }
    
    public var reorderSupport: CollectionViewReorderSupport<Cell.VM>? {
        didSet {
            guard let _ = self.reorderSupport else { return }
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView.addGestureRecognizer(longPressGesture)
        }
    }
    
    public var pullToRefreshSupport: CollectionViewPullToRefreshSupport<Cell.VM>? {
        didSet {
            guard let pullToRefreshSupport = self.pullToRefreshSupport else {
                self.collectionView.refreshControl = nil
                return
            }

            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = pullToRefreshSupport.tintColor
            refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
            self.collectionView.refreshControl = refreshControl
        }
    }

    public var supplementaryViewSupport: CollectionViewSupplementaryViewSupport? {
        didSet {
            defer {
                collectionView.reloadData()
            }
            guard let supplementaryViewSupport = self.supplementaryViewSupport else {
                return
            }
            
            collectionView.register(
                supplementaryViewSupport.supplementaryViewClass,
                forSupplementaryViewOfKind: supplementaryViewSupport.kind.toUIKit(),
                withReuseIdentifier: Constants.SupplementaryViewReuseID
            )
        }
    }

    public func updateData(_ data: [Cell.VM]) {
        self.data = data
        collectionView.reloadData()
    }
    
    public func performEditActions(_ actions: [CollectionViewEditActionKind<Cell.VM>]) {
        
        collectionView.performBatchUpdates({
            actions.forEach {
                switch $0 {
                case .remove(let fromIndexPath):
                    data.remove(at: fromIndexPath.item)
                    collectionView.deleteItems(at: [fromIndexPath])
                case .insert(let item, let indexPath):
                    data.insert(item, at: indexPath.item)
                    collectionView.insertItems(at: [indexPath])
                case .move(let from, let to):
                    data.moveItem(fromIndex: from.item, toIndex: to.item)
                    collectionView.moveItem(at: from, to: to)
                case .reload(let model, let indexPath):
                    data[indexPath.item] = model
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }, completion: nil)
    }
    
    //MARK:- UICollectionViewDataSource

    @objc public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyView() }
        let infiniteCellCount: Int = (self.infiniteScrollSupport == nil) ? 0 : 1
        return self.data.count + infiniteCellCount
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isInfiniteLoadingIndex(indexPath) {
            let cell: InfiniteLoadingCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.configureFor(viewModel: ())
            infiniteScrollSupport?.configureCell(cell)
            loadingCollectionViewCell = cell
            return cell
        } else {
            let cell: Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
            let model = data[indexPath.item]
            cell.configureFor(viewModel: model)
            return cell
        }
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reorderSupport = self.reorderSupport else { return false }
        return reorderSupport.canMoveItemAtIndexPath(indexPath)
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let commitMoveHandler = reorderSupport?.didMoveItemAtIndexPath else { return }
        let movedItem = data[destinationIndexPath.item]
        data.moveItem(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
        commitMoveHandler(sourceIndexPath, destinationIndexPath, movedItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryViewSupport = self.supplementaryViewSupport else {
            fatalError()
        }
        
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(
            ofKind: supplementaryViewSupport.kind.toUIKit(),
            withReuseIdentifier: Constants.SupplementaryViewReuseID,
            for: indexPath
        )
        supplementaryViewSupport.configureHeader(supplementaryView)
        supplementaryView.isHidden = (data.count == 0) && supplementaryViewSupport.shouldHideOnEmptyDataSet
        return supplementaryView
    }
    
    //MARK:- Private
    
    private func isInfiniteLoadingIndex(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == data.count && self.infiniteScrollSupport != nil
    }
    
    private func requestNextInfiniteScrollPage() {
        guard !isRequestingNextPage, let infiniteScrollSupport = self.infiniteScrollSupport else { return }
        isRequestingNextPage = true
        infiniteScrollSupport.fetchHandler { [weak self] result in
            guard let `self` = self else { return }
            self.isRequestingNextPage = false
            let dataCount = self.data.count
            if let newData = result.newDataAvailable, !newData.isEmpty {
                var newIndex = 0
                let actions: [CollectionViewEditActionKind<Cell.VM>] = newData.map {
                    defer { newIndex += 1 }
                    return .insert(item: $0, atIndexPath: IndexPath(item: dataCount + newIndex, section: 0))
                }
                self.performEditActions(actions)
            }
            
            if result.shouldKeepPaging { /* User requested to keep paging */ return }

            // Clear this property since we're no longer allowing paging
            self.infiniteScrollSupport = nil
            
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: dataCount, section: 0)])
            }, completion: { _ in })
        }
    }

    private func addEmptyView() {
        
        guard let emptyConfiguration = self.emptyConfiguration else {
            return
        }
        
        self.emptyView?.removeFromSuperview()
        
        if data.count == 0 {
            emptyView = emptyConfiguration.viewRepresentation()
        } else {
            emptyView = nil
        }
        
        guard let emptyView = self.emptyView, let collectionView = self.collectionView else { return }
        
        collectionView.addAutolayoutSubview(emptyView)
        
        let spacing = Constants.Spacing
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyView.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor, constant: spacing),
            emptyView.trailingAnchor.constraint(greaterThanOrEqualTo: collectionView.trailingAnchor, constant: -spacing)
            ])
    }
    
    //MARK: IBAction

    @objc func handlePullToRefresh() {
        guard let pullToRefreshSupport = self.pullToRefreshSupport else { return }
        
        pullToRefreshSupport.handler({ [weak self] behavior in
            guard let `self` = self else { return }
            self.collectionView.refreshControl?.endRefreshing()
            switch behavior {
            case .insertOnTop(let newModels):
                self.collectionView.performBatchUpdates({
                    self.data.insert(contentsOf: newModels, at: 0)
                    let newIndexPaths = newModels.enumerated().map({ (idx, element) -> IndexPath in
                        return IndexPath(item: idx, section: 0)
                    })
                    self.collectionView.insertItems(at: newIndexPaths)
                }, completion: nil)
            case .replace(let newModels):
                self.data = newModels
                self.collectionView.reloadData()
            case .noNewContent:
                break
            }
        })
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

//MARK: - Edit Support

public enum CollectionViewEditActionKind<Model> {
    case insert(item: Model, atIndexPath: IndexPath)
    case remove(fromIndexPath: IndexPath)
    case move(fromIndexPath: IndexPath, toIndexPath: IndexPath)
    case reload(item: Model, indexPath: IndexPath)
}

//MARK: - Reorder Support

public struct CollectionViewReorderSupport<Model> {
    public typealias DidMoveItemHandler = ((_ from: IndexPath, _ to: IndexPath, _ movedItem: Model) -> Void)
    public typealias CanMoveItemHandler = ((IndexPath) -> Bool)
    
    public let canMoveItemAtIndexPath: CanMoveItemHandler
    public let didMoveItemAtIndexPath: DidMoveItemHandler
    
    public init(canMoveItemAtIndexPath: @escaping CanMoveItemHandler, didMoveItemAtIndexPath: @escaping DidMoveItemHandler) {
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
        self.didMoveItemAtIndexPath = didMoveItemAtIndexPath
    }
}

//MARK: - Pull to Refresh Support

public struct CollectionViewPullToRefreshSupport<Model> {
    public enum Behavior {
        case replace([Model])
        case insertOnTop([Model])
        case noNewContent
    }
    public typealias Handler = (@escaping (Behavior) -> ()) -> ()
    public let tintColor: UIColor?
    public let handler: Handler

    public init(tintColor: UIColor? = nil, handler: @escaping Handler) {
        self.handler = handler
        self.tintColor = tintColor
    }
}

//MARK: - SupplementaryViewSupport

public struct CollectionViewSupplementaryViewSupport {

    public typealias ConfigureHeader = (UICollectionReusableView) -> ()

    public let kind: UICollectionView.SupplementaryViewKind
    public let configureHeader: ConfigureHeader
    public let shouldHideOnEmptyDataSet: Bool
    public let supplementaryViewClass: UICollectionReusableView.Type

    public init(supplementaryViewClass: UICollectionReusableView.Type, kind: UICollectionView.SupplementaryViewKind, shouldHideOnEmptyDataSet: Bool = false, configureHeader: @escaping ConfigureHeader) {
        self.supplementaryViewClass = supplementaryViewClass
        self.kind = kind
        self.shouldHideOnEmptyDataSet = shouldHideOnEmptyDataSet
        self.configureHeader = configureHeader
    }
}

//MARK: - Infinite Scroll support

public struct CollectionViewInfiniteScrollSupport<Model> {
    public struct FetchResult {
        let newDataAvailable: [Model]?
        let shouldKeepPaging: Bool
        public init(newDataAvailable: [Model]?, shouldKeepPaging: Bool) {
            self.newDataAvailable = newDataAvailable
            self.shouldKeepPaging = shouldKeepPaging
        }
    }
    public typealias ConfigureCell = (InfiniteLoadingCollectionViewCell) -> ()
    public typealias FetchHandler = (@escaping (FetchResult) -> ()) -> ()

    public let configureCell: ConfigureCell
    public let fetchHandler: FetchHandler

    public init(configureCell: @escaping ConfigureCell, fetchHandler: @escaping FetchHandler) {
        self.configureCell = configureCell
        self.fetchHandler = fetchHandler
    }
}

private enum Constants {
    static let SupplementaryViewReuseID = "SupplementaryViewReuseID"
    static let Spacing: CGFloat = 20
}
