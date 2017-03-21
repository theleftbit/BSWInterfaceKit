//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class CollectionViewStatefulDataSource<Cell:ViewModelReusable>: NSObject, UICollectionViewDataSource where Cell:UICollectionViewCell {
    
    public fileprivate(set) var state: ListState<Cell.VM>
    public weak var collectionView: UICollectionView?
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
        
        switch Cell.reuseType {
        case .classReference(let classReference):
            collectionView.register(classReference, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        case .nib(let nib):
            collectionView.register(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }

        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        if let _ = self.reorderSupport {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView?.addGestureRecognizer(longPressGesture)
        }
    }
    
    public func updateState(_ state: ListState<Cell.VM>) {
        self.state = state
        collectionView?.reloadData()
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
            
            collectionView?.performEditActions(actions)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError()
        }
        
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
    
    //MARK:- Private
    
    fileprivate func addEmptyViewForCurrentState() {
        
        guard let listPresenter = self.listPresenter else {
            print("I need a list presenter")
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
