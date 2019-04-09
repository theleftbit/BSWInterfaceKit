//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public class CollectionViewDataSource<Cell:ViewModelReusable & UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    public private(set) var data: [Cell.VM]
    public weak var collectionView: UICollectionView!
    public var emptyConfiguration: ErrorView.Configuration?
    public let reorderSupport: CollectionViewReorderSupport<Cell.VM>?
    private var emptyView: UIView?

    public init(data: [Cell.VM] = [],
                collectionView: UICollectionView,
                emptyConfiguration: ErrorView.Configuration? = nil,
                reorderSupport: CollectionViewReorderSupport<Cell.VM>? = nil) {
        self.data = data
        self.collectionView = collectionView
        self.emptyConfiguration = emptyConfiguration
        self.reorderSupport = reorderSupport
        
        super.init()

        collectionView.registerReusableCell(Cell.self)
        collectionView.dataSource = self
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
        guard let commitMoveHandler = reorderSupport?.moveItemAtIndexPath else { return }
        let movedItem = data[(destinationIndexPath as NSIndexPath).item]
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

private enum Constants {
    static let SupplementaryViewReuseID = "SupplementaryViewReuseID"
    static let Spacing: CGFloat = 20
}
