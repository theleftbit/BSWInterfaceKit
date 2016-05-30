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

    public var state: ListState<Model> {
        didSet {
            collectionView?.reloadData()
        }
    }
    public weak var collectionView: UICollectionView?
    public unowned let listPresenter: ListStatePresenter
    public let mapper: ModelMapper
    private var emptyView: UIView?
    
    public init(state: ListState<Model>,
                collectionView: UICollectionView,
                listPresenter: ListStatePresenter,
                mapper: ModelMapper) {
        self.state = state
        self.collectionView = collectionView
        self.listPresenter = listPresenter
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

    @objc public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        defer { addEmptyViewForCurrentState() }
        
        switch self.state {
        case .Failure(_):
            return 0
        case .Loading(_):
            return 0
        case .Loaded(let models):
            return models.count
        }
    }
    
    @objc public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    }
    
    //MARK:- Private
    
    private func addEmptyViewForCurrentState() {
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
}
