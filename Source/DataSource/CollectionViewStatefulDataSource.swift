//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

public class CollectionViewStatefulDataSource<Model, Cell:ViewModelReusable where Cell:UICollectionViewCell> {
    
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

    public init(state: ListState<Model>,
                collectionView: UICollectionView,
                listPresenter: ListStatePresenter,
                mapper: ModelMapper) {
        self.state = state
        self.collectionView = collectionView
        self.listPresenter = listPresenter
        self.mapper = mapper
        
        switch Cell.reuseType {
        case .ClassReference(let classReference):
            collectionView.registerClass(classReference, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        case .NIB(let nib):
            collectionView.registerNib(nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        }

        collectionView.dataSource = bridgedDataSource
        collectionView.emptyDataSetSource = bridgedDataSource
        collectionView.emptyDataSetDelegate = bridgedDataSource
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
        customViewForEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Custom(let view):
                    return view
                default:
                    return nil
                }
            case .Loading(_):
                switch self.listPresenter.loadingConfiguration {
                case .Custom(let view):
                    return view
                case .Default(let configuration):
                    let loadingView = LoadingView(loadingMessage: configuration.message, activityIndicatorStyle: configuration.activityIndicatorStyle)
                    loadingView.backgroundColor = configuration.backgroundColor
                    return loadingView
                }
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Custom(let view):
                    return view
                default:
                    return nil
                }
            }
        },
        titleEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Default(let configuration):
                    return configuration.title
                default:
                    return nil
                }
            case .Loading(_):
                return nil
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Default(let configuration):
                    return configuration.title
                default:
                    return nil
                }
            }
        },
        detailForEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Default(let configuration):
                    return configuration.message
                default:
                    return nil
                }
            case .Loading(_):
                return nil
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Default(let configuration):
                    return configuration.message
                default:
                    return nil
                }
            }
        },
        imageForEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Default(let configuration):
                    return configuration.image
                default:
                    return nil
                }
            case .Loading(_):
                return nil
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Default(let configuration):
                    return configuration.image
                default:
                    return nil
                }
            }
        },
        buttonTitleForEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Default(let configuration):
                    return configuration.buttonConfiguration?.title
                default:
                    return nil
                }
            case .Loading(_):
                return nil
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Default(let configuration):
                    return configuration.buttonConfiguration?.title
                default:
                    return nil
                }
            }
        },
        buttonTapForEmptyDataSetHandler: {
            switch self.state {
            case .Failure(let error):
                switch self.listPresenter.errorConfiguration(forError:error) {
                case .Default(let configuration):
                    configuration.buttonConfiguration?.actionHandler()
                default:
                    break
                }
            case .Loading(_):
                break
            case .Loaded(let models):
                switch self.listPresenter.emptyConfiguration {
                case .Default(let configuration):
                    configuration.buttonConfiguration?.actionHandler()
                default:
                    break
                }
            }
        }
    )
}

/*
 Avoid making CollectionViewStatefulDataSource inherit from NSObject.
 Keep classes pure Swift.
 Keep responsibilies focused.
 */
@objc private final class BridgedCollectionDataSource: NSObject, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    typealias NumberOfRowsInSectionHandler = (Int) -> Int
    typealias CellForItemAtIndexPathHandler = (UICollectionView, NSIndexPath) -> UICollectionViewCell

    typealias CustomViewForEmptyDataSetHandler = (Void) -> UIView?
    typealias AttributedStringForEmptyDataSetHandler = (Void) -> NSAttributedString?
    typealias ImageForEmptyDataSetHandler = (Void) -> UIImage?
    typealias ButtonTapForEmptyDataSetHandler = (Void) -> Void
    
    let numberOfRowsInSection: NumberOfRowsInSectionHandler
    let cellForItemAtIndexPath: CellForItemAtIndexPathHandler
    let customViewForEmptyDataSetHandler: CustomViewForEmptyDataSetHandler
    let titleEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler
    let detailForEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler
    let imageForEmptyDataSetHandler: ImageForEmptyDataSetHandler
    let buttonTitleForEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler
    let buttonTapForEmptyDataSetHandler: ButtonTapForEmptyDataSetHandler

    init(numberOfRowsInSection: NumberOfRowsInSectionHandler,
         cellForItemAtIndexPath: CellForItemAtIndexPathHandler,
         customViewForEmptyDataSetHandler: CustomViewForEmptyDataSetHandler,
         titleEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler,
         detailForEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler,
         imageForEmptyDataSetHandler: ImageForEmptyDataSetHandler,
         buttonTitleForEmptyDataSetHandler: AttributedStringForEmptyDataSetHandler,
         buttonTapForEmptyDataSetHandler: ButtonTapForEmptyDataSetHandler) {
        self.numberOfRowsInSection = numberOfRowsInSection
        self.cellForItemAtIndexPath = cellForItemAtIndexPath
        self.customViewForEmptyDataSetHandler = customViewForEmptyDataSetHandler
        self.titleEmptyDataSetHandler = titleEmptyDataSetHandler
        self.detailForEmptyDataSetHandler = detailForEmptyDataSetHandler
        self.imageForEmptyDataSetHandler = imageForEmptyDataSetHandler
        self.buttonTitleForEmptyDataSetHandler = buttonTitleForEmptyDataSetHandler
        self.buttonTapForEmptyDataSetHandler = buttonTapForEmptyDataSetHandler
    }

    //MARK:- UICollectionViewDataSource

    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellForItemAtIndexPath(collectionView, indexPath)
    }
    
    //MARK:- Empty Data Source
    
    @objc func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        return customViewForEmptyDataSetHandler()
    }
    
    @objc func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return titleEmptyDataSetHandler()
    }
    
    @objc func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return detailForEmptyDataSetHandler()
    }
    
    @objc func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return imageForEmptyDataSetHandler()
    }

    @objc func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        return buttonTitleForEmptyDataSetHandler()
    }
    
    @objc func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        buttonTapForEmptyDataSetHandler()
    }
}

