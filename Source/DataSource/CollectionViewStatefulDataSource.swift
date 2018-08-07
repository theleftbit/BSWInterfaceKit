//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public class CollectionViewStatefulDataSource<Cell:ViewModelReusable & UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    public fileprivate(set) var state: ListState<Cell.VM>
    public weak var collectionView: UICollectionView!
    public weak var listPresenter: ListStatePresenter?
    fileprivate var emptyView: UIView?
    public let reorderSupport: CollectionViewReorderSupport<Cell.VM>?
    
    public init(state: ListState<Cell.VM> = .loading,
                collectionView: UICollectionView,
                listPresenter: ListStatePresenter? = nil,
                reorderSupport: CollectionViewReorderSupport<Cell.VM>? = nil) {
        self.state = state
        self.collectionView = collectionView
        self.listPresenter = listPresenter
        self.reorderSupport = reorderSupport
        
        super.init()

        collectionView.registerReusableCell(Cell.self)
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        if let _ = self.reorderSupport {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView.addGestureRecognizer(longPressGesture)
        }
    }

    public var pullToRefreshSupport: CollectionViewPullToRefreshSupport<Cell.VM>? {
        didSet {
            guard #available (iOS 10.0, *) else {
                return
            }
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

    public func updateState(_ state: ListState<Cell.VM>) {
        self.state = state
        collectionView.reloadData()
    }
    
    public func performEditActions(_ actions: [CollectionViewEditActionKind<Cell.VM>]) {
        if case .loaded(var models) = self.state {
            actions.forEach {
                switch $0 {
                case .insert(let item, let indexPath):
                    models.insert(item, at: indexPath.item)
                    self.state = .loaded(data: models)
                case .remove(let fromIndexPath):
                    models.remove(at: fromIndexPath.item)
                    self.state = .loaded(data: models)
                case .move(let from, let to):
                    models.moveItem(fromIndex: from.item, toIndex: to.item)
                    self.state = .loaded(data: models)
                case .reload(let model, let indexPath):
                    models[indexPath.item] = model
                    self.state = .loaded(data: models)
                }
            }
            
            collectionView.performEditActions(actions)
        }
    }

    public func modelForIndexPath(_ indexPath: IndexPath) -> Cell.VM? {
        switch self.state {
        case .loaded(let data):
            return data[indexPath.item]
        default:
            return nil
        }
    }
    
    //MARK:- UICollectionViewDataSource

    @objc public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyViewForCurrentState() }
        
        switch self.state {
        case .loaded(let models):
            return models.count
        default:
            return 0
        }
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if case .loaded(let models) = self.state {
            let model = models[indexPath.item]
            cell.configureFor(viewModel: model)
        }
        return cell
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reorderSupport = self.reorderSupport else { return false }
        return reorderSupport.canMoveItemAtIndexPath(indexPath)
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let commitMoveHandler = reorderSupport?.moveItemAtIndexPath else { return }
        if case .loaded(var models) = self.state {
            let movedItem = models[(destinationIndexPath as NSIndexPath).item]
            models.moveItem(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
            self.state = .loaded(data: models)
            commitMoveHandler(sourceIndexPath, destinationIndexPath, movedItem)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryViewSupport = self.supplementaryViewSupport else {
            return UICollectionReusableView()
        }
        
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(
            ofKind: supplementaryViewSupport.kind.toUIKit(),
            withReuseIdentifier: Constants.SupplementaryViewReuseID,
            for: indexPath
        )
        supplementaryViewSupport.configureHeader(supplementaryView)
        supplementaryView.isHidden = (self.state.data == nil)
        return supplementaryView
    }
    
    //MARK:- Private
    
    fileprivate func addEmptyViewForCurrentState() {
        
        guard let listPresenter = self.listPresenter else {
            return
        }
        
        self.emptyView?.removeFromSuperview()
        
        switch state {
        case .loading:
            switch listPresenter.loadingConfiguration {
            case .custom(let view):
                emptyView = view
            case .default(let configuration):
                let loadingView = LoadingView(
                    loadingMessage: configuration.message,
                    activityIndicatorStyle: configuration.activityIndicatorStyle
                )
                loadingView.backgroundColor = configuration.backgroundColor
                emptyView = loadingView
            }
        case .failure(let error):
            switch listPresenter.errorConfiguration(forError: error) {
            case .custom(let view):
                emptyView = view
            case .default(let config):
                emptyView = config.viewRepresentation()
            }
        case .loaded(let data):
            if data.count == 0 {
                switch listPresenter.emptyConfiguration {
                case .custom(let view):
                    emptyView = view
                case .default(let config):
                    emptyView = config.viewRepresentation()
                }
            } else {
                emptyView = nil
            }
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
                    self.state.addingData(newData: newModels)
                    let newIndexPaths = newModels.enumerated().map({ (idx, element) -> IndexPath in
                        return IndexPath(item: idx, section: 0)
                    })
                    self.collectionView.insertItems(at: newIndexPaths)
                }, completion: nil)
            case .replace(let newModels):
                self.state.replaceData(forNewData: newModels)
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

//MARK: - Reorder Support

public enum CollectionViewEditActionKind<Model> {
    case insert(item: Model, atIndexPath: IndexPath)
    case remove(fromIndexPath: IndexPath)
    case move(fromIndexPath: IndexPath, toIndexPath: IndexPath)
    case reload(item: Model, indexPath: IndexPath)
}

public struct CollectionViewReorderSupport<Model> {
    public typealias CommitMoveItemHandler = ((_ from: IndexPath, _ to: IndexPath, _ movedItem: Model) -> Void)
    public typealias CanMoveItemHandler = ((IndexPath) -> Bool)
    
    public let canMoveItemAtIndexPath: CanMoveItemHandler
    public let moveItemAtIndexPath: CommitMoveItemHandler
}

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

public struct CollectionViewSupplementaryViewSupport {

    public typealias ConfigureHeader = (UICollectionReusableView) -> ()

    public let kind: UICollectionView.SupplementaryViewKind
    public let configureHeader: ConfigureHeader
    public let supplementaryViewClass: UICollectionReusableView.Type
    
    public init(supplementaryViewClass: UICollectionReusableView.Type, kind: UICollectionView.SupplementaryViewKind, configureHeader: @escaping ConfigureHeader) {
        self.supplementaryViewClass = supplementaryViewClass
        self.kind = kind
        self.configureHeader = configureHeader
    }
}

extension UICollectionView {
    fileprivate func performEditActions<T>(_ actions: [CollectionViewEditActionKind<T>]) {
        performBatchUpdates({ 
            
            actions.forEach {
                switch $0 {
                case .remove(let from):
                    self.deleteItems(at: [from])
                case .insert(_, let at):
                    self.insertItems(at: [at])
                case .move(let from, let to):
                    self.moveItem(at: from, to: to)
                case .reload(_, let indexPath):
                    self.reloadItems(at: [indexPath])
                }
            }

            }, completion: nil)
    }
}

private enum Constants {
    static let SupplementaryViewReuseID = "SupplementaryViewReuseID"
    static let Spacing: CGFloat = 20
}
