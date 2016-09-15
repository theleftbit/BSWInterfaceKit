//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

open class CollectionViewStatefulDataSource<Model, Cell:ViewModelReusable>: NSObject, UICollectionViewDataSource where Cell:UICollectionViewCell {
    
    /// This is mapper is neccesary since we couldn't figure out how map
    /// the types using just protocols, since making the generics type of both
    /// ConfigurableCell and Model match impossible as of Swift 2.2

    public typealias ModelMapper = (Model) -> Cell.VM
    
    open fileprivate(set) var state: ListState<Model>
    open weak var collectionView: UICollectionView?
    open weak var listPresenter: ListStatePresenter?
    open let mapper: ModelMapper
    fileprivate var emptyView: UIView?
    open let reorderSupport: CollectionViewReorderSupport<Model>?
    
    public init(state: ListState<Model> = .loading,
                collectionView: UICollectionView,
                listPresenter: ListStatePresenter? = nil,
                reorderSupport: CollectionViewReorderSupport<Model>? = nil,
                mapper: @escaping ModelMapper) {
        self.state = state
        self.collectionView = collectionView
        self.listPresenter = listPresenter
        self.reorderSupport = reorderSupport
        self.mapper = mapper
        
        super.init()
        
        switch Cell.reuseType {
        case .classReference(let classReference):
            collectionView.register(classReference, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        case .nib(let nib):
            collectionView.register(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }

        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        if let reorderSupport = self.reorderSupport {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView?.addGestureRecognizer(longPressGesture)
        }
    }
    
    open func updateState(_ state: ListState<Model>) {
        self.state = state
        collectionView?.reloadData()
    }
    
    open func performEditActions(_ actions: [CollectionViewEditActionKind<Model>]) {
        if case .loaded(var models) = self.state {
            actions.forEach {
                switch $0 {
                case .insert(let item, let indexPath):
                    models.insert(item, at: (indexPath as NSIndexPath).item)
                    self.state = .loaded(data: models)
                case .remove(let fromIndexPath):
                    models.remove(at: (fromIndexPath as NSIndexPath).item)
                    self.state = .loaded(data: models)
                case .move(let from, let to):
                    models.moveItem(fromIndex: from.item, toIndex: to.item)
                    self.state = .loaded(data: models)
                case .reload(let model, let indexPath):
                    models[(indexPath as NSIndexPath).item] = model
                    self.state = .loaded(data: models)
                }
            }
            
            collectionView?.performEditActions(actions)
        }
    }

    open func modelForIndexPath(_ indexPath: IndexPath) -> Model? {
        switch self.state {
        case .loaded(let data):
            return data[(indexPath as NSIndexPath).row]
        default:
            return nil
        }
    }
    
    //MARK:- UICollectionViewDataSource

    @objc open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyViewForCurrentState() }
        
        switch self.state {
        case .loaded(let models):
            return models.count
        default:
            return 0
        }
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError()
        }
        
        if case .loaded(let models) = self.state {
            let model = models[(indexPath as NSIndexPath).row]
            let viewModel = self.mapper(model)
            cell.configureFor(viewModel: viewModel)
        }
        
        return cell
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let reorderSupport = self.reorderSupport else { return false }
        return reorderSupport.canMoveItemAtIndexPath(indexPath)
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let commitMoveHandler = reorderSupport?.moveItemAtIndexPath else { return }
        if case .loaded(var models) = self.state {
            let movedItem = models[(destinationIndexPath as NSIndexPath).item]
            models.moveItem(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
            self.state = .loaded(data: models)
            commitMoveHandler(sourceIndexPath, destinationIndexPath, movedItem)
        }
    }
    
    //MARK:- Private
    
    fileprivate func addEmptyViewForCurrentState() {
        
        guard let listPresenter = self.listPresenter else { return }
        
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
        
        collectionView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        emptyView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -20).isActive = true
    }
    
    //MARK: IBAction
    
    func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
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

extension UICollectionView {
    fileprivate func performEditActions<T>(_ actions: [CollectionViewEditActionKind<T>]) {
        performBatchUpdates({ 
            
            actions.forEach {
                switch $0 {
                case .remove(let from):
                    self.deleteItems(at: [from])
                case .insert(let _, let at):
                    self.insertItems(at: [at])
                case .move(let from, let to):
                    self.moveItem(at: from, to: to)
                case .reload(let _, let indexPath):
                    self.reloadItems(at: [indexPath])
                }
            }

            }, completion: nil)
    }
}
