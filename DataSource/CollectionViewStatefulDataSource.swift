//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class CollectionViewStatefulDataSource<Model, Cell:ConfigurableCell where Cell:UICollectionViewCell> {
    
    /// This is mapper is neccesary since we couldn't figure out how map
    /// the types using just protocols, since making the generics type of both
    /// ConfigurableCell and Model match impossible as of Swift 2.2

    public typealias ModelMapper = (Model) -> Cell.T

    public var state: ListState<Model> {
        didSet {
            collectionView?.reloadData()
        }
    }
    public weak var collectionView: UICollectionView?
    public let mapper: ModelMapper

    public init(state: ListState<Model>, collectionView: UICollectionView, mapper: ModelMapper) {
        self.state = state
        self.collectionView = collectionView
        self.mapper = mapper
        
        switch Cell.reuseType {
        case .ClassReference(let classReference):
            collectionView.registerClass(classReference, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        case .NIB(let nib):
            collectionView.registerNib(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }

        collectionView.dataSource = bridgedDataSource
        collectionView.delegate = bridgedDataSource
    }
    
    // MARK: Private
    
    private lazy var bridgedDataSource: BridgedCollectionDataSource = BridgedCollectionDataSource(
        numberOfRowsInSection: { [unowned self] (section) -> Int in
            
            switch self.state {
            case .Failure(_):
                return 0
            case .Loading(_):
                return 0
            case .Loaded(let models):
                return models.count
            }
            
            return 0
        },
        cellForItemAtIndexPath: { [unowned self] (collectionView, indexPath) -> UICollectionViewCell in
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.reuseIdentifier, forIndexPath: indexPath) as! Cell
            
            switch self.state {
            case .Failure(_):
                break
            case .Loading(_):
                break
            case .Loaded(let models):
                let model = models[indexPath.row]
                let viewModel = self.mapper(model)
                cell.configureFor(viewModel: viewModel)
            }

            return cell
        },
        cellTappedAtIndexPath: { indexPath in
            
        }
    )
}

/*
 Avoid making CollectionViewStatefulDataSource inherit from NSObject.
 Keep classes pure Swift.
 Keep responsibilies focused.
 */
@objc private final class BridgedCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias NumberOfRowsInSectionHandler = (Int) -> Int
    typealias CellForItemAtIndexPathHandler = (UICollectionView, NSIndexPath) -> UICollectionViewCell
    typealias CellTappedHandler = (NSIndexPath) -> Void
    
    let numberOfRowsInSection: NumberOfRowsInSectionHandler
    let cellForItemAtIndexPath: CellForItemAtIndexPathHandler
    let cellTappedAtIndexPath: CellTappedHandler
    
    init(numberOfRowsInSection: NumberOfRowsInSectionHandler,
         cellForItemAtIndexPath: CellForItemAtIndexPathHandler,
         cellTappedAtIndexPath: CellTappedHandler) {
        self.numberOfRowsInSection = numberOfRowsInSection
        self.cellForItemAtIndexPath = cellForItemAtIndexPath
        self.cellTappedAtIndexPath = cellTappedAtIndexPath
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellForItemAtIndexPath(collectionView, indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cellTappedAtIndexPath(indexPath)
    }
}