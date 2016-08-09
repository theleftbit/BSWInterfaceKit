//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class CollectionViewStatefulDataSource<Model, Cell:ViewModelReusable where Cell:UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    /// This is mapper is neccesary since we couldn't figure out how map
    /// the types using just protocols, since making the generics type of both
    /// ConfigurableCell and Model match impossible as of Swift 2.2

    public typealias ModelMapper = (Model) -> Cell.VM
    
    public private(set) var state: ListState<Model>
    public weak var collectionView: UICollectionView?
    public weak var listPresenter: ListStatePresenter?
    public let mapper: ModelMapper
    private var emptyView: UIView?
    public let reorderSupport: CollectionViewReorderSupport?
    
    public init(state: ListState<Model> = .Loading,
                collectionView: UICollectionView,
                listPresenter: ListStatePresenter? = nil,
                reorderSupport: CollectionViewReorderSupport? = nil,
                mapper: ModelMapper) {
        self.state = state
        self.collectionView = collectionView
        self.listPresenter = listPresenter
        self.reorderSupport = reorderSupport
        self.mapper = mapper
        
        super.init()
        
        switch Cell.reuseType {
        case .ClassReference(let classReference):
            collectionView.registerClass(classReference, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        case .NIB(let nib):
            collectionView.registerNib(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }

        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        if let reorderSupport = self.reorderSupport {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
            self.collectionView?.addGestureRecognizer(longPressGesture)
        }
    }
    
    public func updateState(state: ListState<Model>) {
        self.state = state
        collectionView?.reloadData()
    }
    
    public func performEditActions(actions: [CollectionViewEditActionKind<Model>]) {
        if case .Loaded(var models) = self.state {
            actions.forEach {
                switch $0 {
                case .Insert(let item, let indexPath):
                    models.insert(item, atIndex: indexPath.item)
                    self.state = .Loaded(data: models)
                case .Remove(let fromIndexPath):
                    models.removeAtIndex(fromIndexPath.item)
                    self.state = .Loaded(data: models)
                case .Move(let from, let to):
                    models.moveItem(fromIndex: from.item, toIndex: to.item)
                    self.state = .Loaded(data: models)
                case .Reload(let model, let indexPath):
                    models[indexPath.item] = model
                    self.state = .Loaded(data: models)
                }
            }
            
            collectionView?.performEditActions(actions)
        }
    }

    public func modelForIndexPath(indexPath: NSIndexPath) -> Model? {
        switch self.state {
        case .Loaded(let data):
            return data[indexPath.row]
        default:
            return nil
        }
    }
    
    //MARK:- UICollectionViewDataSource

    @objc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyViewForCurrentState() }
        
        switch self.state {
        case .Loaded(let models):
            return models.count
        default:
            return 0
        }
    }
    
    @objc public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.reuseIdentifier, forIndexPath: indexPath) as? Cell else {
            fatalError()
        }
        
        if case .Loaded(let models) = self.state {
            let model = models[indexPath.row]
            let viewModel = self.mapper(model)
            cell.configureFor(viewModel: viewModel)
        }
        
        return cell
    }
    
    @objc public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let reorderSupport = self.reorderSupport else { return false }
        return reorderSupport.canMoveItemAtIndexPath(indexPath)
    }
    
    @objc public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard let commitMoveHandler = reorderSupport?.moveItemAtIndexPath else { return }
        if case .Loaded(var models) = self.state {
            models.moveItem(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
            self.state = .Loaded(data: models)
            commitMoveHandler(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    //MARK:- Private
    
    private func addEmptyViewForCurrentState() {
        
        guard let listPresenter = self.listPresenter else { return }
        
        self.emptyView?.removeFromSuperview()
        
        switch state {
        case .Loading:
            switch listPresenter.loadingConfiguration {
            case .Custom(let view):
                emptyView = view
            case .Default(let configuration):
                let loadingView = LoadingView(
                    loadingMessage: configuration.message,
                    activityIndicatorStyle: configuration.activityIndicatorStyle
                )
                loadingView.backgroundColor = configuration.backgroundColor
                emptyView = loadingView
            }
        case .Failure(let error):
            switch listPresenter.errorConfiguration(forError: error) {
            case .Custom(let view):
                emptyView = view
            case .Default(let config):
                emptyView = config.viewRepresentation()
            }
        case .Loaded(let data):
            if data.count == 0 {
                switch listPresenter.emptyConfiguration {
                case .Custom(let view):
                    emptyView = view
                case .Default(let config):
                    emptyView = config.viewRepresentation()
                }
            } else {
                emptyView = nil
            }
        }
        
        guard let emptyView = self.emptyView, collectionView = self.collectionView else { return }
        
        collectionView.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.centerXAnchor.constraintEqualToAnchor(collectionView.centerXAnchor).active = true
        emptyView.centerYAnchor.constraintEqualToAnchor(collectionView.centerYAnchor, constant: -20).active = true
    }
    
    //MARK: IBAction
    
    func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        
        switch(gesture.state) {
        case .Began:
            guard let selectedIndexPath = collectionView.indexPathForItemAtPoint(gesture.locationInView(collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case .Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case .Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

//MARK: - Reorder Support

public enum CollectionViewEditActionKind<Model> {
    case Insert(item: Model, atIndexPath: NSIndexPath)
    case Remove(fromIndexPath: NSIndexPath)
    case Move(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    case Reload(item: Model, indexPath: NSIndexPath)
}

public struct CollectionViewReorderSupport {
    public typealias CommitMoveItemHandler = ((from: NSIndexPath, to: NSIndexPath) -> Void)
    public typealias CanMoveItemHandler = (NSIndexPath -> Bool)
    
    public let canMoveItemAtIndexPath: CanMoveItemHandler
    public let moveItemAtIndexPath: CommitMoveItemHandler
}

extension UICollectionView {
    private func performEditActions<T>(actions: [CollectionViewEditActionKind<T>]) {
        performBatchUpdates({ 
            
            actions.forEach {
                switch $0 {
                case .Remove(let from):
                    self.deleteItemsAtIndexPaths([from])
                case .Insert(let _, let at):
                    self.insertItemsAtIndexPaths([at])
                case .Move(let from, let to):
                    self.moveItemAtIndexPath(from, toIndexPath: to)
                case .Reload(let _, let indexPath):
                    self.reloadItemsAtIndexPaths([indexPath])
                }
            }

            }, completion: nil)
    }
}