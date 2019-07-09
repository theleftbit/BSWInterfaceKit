//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import BSWFoundation

public class CollectionViewDataSource<Cell:ViewModelReusable & UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    public private(set) var data: [Cell.VM]
    public weak var collectionView: UICollectionView!
    public var emptyConfiguration: ErrorView.Configuration?
    private var emptyView: UIView?
    private var offsetObserver: NSKeyValueObservation?
    private var isRequestingNextPage: Bool = false
    private var scrollDirection: UICollectionView.ScrollDirection {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return .vertical
        }
        return flowLayout.scrollDirection
    }
    
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
    
    public var reorderSupport: CollectionViewReorderSupport<Cell.VM>? {
        didSet {
            guard let _ = self.reorderSupport else { return }
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView.addGestureRecognizer(longPressGesture)
        }
    }
    
    public var infiniteScrollSupport: CollectionViewInfiniteScrollSupport<Cell.VM>? {
        didSet {
            defer {
                collectionView.reloadData()
            }
            guard let infiniteScrollSupport = self.infiniteScrollSupport else {
                offsetObserver = nil
                if let columnLayout = self.collectionView.collectionViewLayout as? ColumnFlowLayout {
                    columnLayout.showsFooter = false
                }
                return
            }
            
            // To ease adoption, we're adding here some callbacks neccesaries
            // to make the layout query the dataSource for the footer
            if let columnLayout = self.collectionView.collectionViewLayout as? ColumnFlowLayout {
                columnLayout.showsFooter = true
                columnLayout.footerFactory = { _ in
                    return infiniteScrollSupport.footerViewClass.init()
                }
            }
            
            collectionView.register(
                infiniteScrollSupport.footerViewClass,
                forSupplementaryViewOfKind: UICollectionView.SupplementaryViewKind.footer.toUIKit(),
                withReuseIdentifier: Constants.InfinitePagingReuseID
            )
            
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
    }

    public func updateData(_ data: [Cell.VM]) {
        self.data = data
        collectionView.reloadData()
    }
    
    public func performEditActions(_ actions: [CollectionViewEditActionKind<Cell.VM>], completion: @escaping VoidHandler = {}) {
        
        guard actions.count > 0 else {
            completion()
            return
        }
        
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
        }, completion: { _ in
            completion()
        })
    }
    
    //MARK:- UICollectionViewDataSource
    
    @objc public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyView() }
        
        return self.data.count
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let model = data[indexPath.item]
        cell.configureFor(viewModel: model)
        return cell
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reorderSupport = self.reorderSupport else { return false }
        return reorderSupport.canMoveItemAtIndexPath(indexPath)
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let commitMoveHandler = reorderSupport?.didMoveItemHandler else { return }
        let movedItem = data[destinationIndexPath.item]
        data.moveItem(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
        commitMoveHandler(sourceIndexPath, destinationIndexPath, movedItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let infiniteScrollSupport = self.infiniteScrollSupport, kind == UICollectionView.elementKindSectionFooter {
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: Constants.InfinitePagingReuseID,
                for: indexPath
            )
            let footer = supplementaryView as! CollectionViewInfiniteFooter
            infiniteScrollSupport.configureFooter(footer)
            return supplementaryView
        } else if let supplementaryViewSupport = self.supplementaryViewSupport {
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: supplementaryViewSupport.kind.toUIKit(),
                withReuseIdentifier: Constants.SupplementaryViewReuseID,
                for: indexPath
            )
            supplementaryViewSupport.configureHeader(supplementaryView)
            supplementaryView.isHidden = (data.count == 0) && supplementaryViewSupport.shouldHideOnEmptyDataSet
            return supplementaryView
        } else {
            fatalError()
        }
    }
    
    //MARK:- Private
    private func requestNextInfiniteScrollPage() {
        guard !isRequestingNextPage, let infiniteScrollSupport = self.infiniteScrollSupport else { return }
        isRequestingNextPage = true
        infiniteScrollSupport.fetchHandler { [weak self] result in
            guard let `self` = self else { return }
            let actions: [CollectionViewEditActionKind<Cell.VM>] = {
                guard let newData = result.newDataAvailable else { return [] }
                let dataCount = self.data.count
                var newIndex = 0
                return newData.map {
                    defer { newIndex += 1 }
                    return .insert(item: $0, atIndexPath: IndexPath(item: dataCount + newIndex, section: 0))
                }
            }()
            self.performEditActions(actions) {
                self.isRequestingNextPage = false
                // No more paging
                if !result.shouldKeepPaging {
                    self.infiniteScrollSupport = nil
                }
            }

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
    
    @available (iOS 10.0, *)
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
    public let didMoveItemHandler: DidMoveItemHandler
    
    public init(canMoveItemAtIndexPath: @escaping CanMoveItemHandler, didMoveItemAtIndexPath: @escaping DidMoveItemHandler) {
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
        self.didMoveItemHandler = didMoveItemAtIndexPath
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

public protocol CollectionViewInfiniteFooter: UICollectionReusableView {
    func startAnimating()
}

public struct CollectionViewInfiniteScrollSupport<Model> {
    public struct FetchResult {
        let newDataAvailable: [Model]?
        let shouldKeepPaging: Bool
        public init(newDataAvailable: [Model]?, shouldKeepPaging: Bool) {
            self.newDataAvailable = newDataAvailable
            self.shouldKeepPaging = shouldKeepPaging
        }
    }
    public typealias ConfigureFooter = (CollectionViewInfiniteFooter) -> ()
    public typealias FetchHandler = (@escaping (FetchResult) -> ()) -> ()
    
    public let footerViewClass: UICollectionReusableView.Type
    public let configureFooter: ConfigureFooter
    public let fetchHandler: FetchHandler
    
    public init(
        footerViewClass: UICollectionReusableView.Type = InfiniteLoadingCollectionViewFooter.self,
        configureFooter: @escaping ConfigureFooter = { $0.startAnimating() },
        fetchHandler: @escaping FetchHandler) {
        self.footerViewClass = footerViewClass
        self.configureFooter = configureFooter
        self.fetchHandler = fetchHandler
    }
}


private enum Constants {
    static let SupplementaryViewReuseID = "SupplementaryViewReuseID"
    static let InfinitePagingReuseID = "InfinitePagingReuseID"
    static let Spacing: CGFloat = 20
}
