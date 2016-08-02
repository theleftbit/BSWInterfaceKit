//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography
import BSWFoundation

protocol EditClassicProfileDelegate: EditClassicProfilePhotoDelegate {
    
}

protocol EditClassicProfilePhotoDelegate: class {
    func didChangePhotoArrangement(fromIndex index: UInt, toIndex: UInt)
    func didRequestDeletePhoto(atIndex index: UInt)
    func didRequestAddPhoto(atIndex index: UInt)
}

public class EditClassicProfileViewController: UIViewController {

    enum Constants {
        static let MaxPhotosCount = 6
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(profile: ClassicProfileViewModel) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    var profile: ClassicProfileViewModel
    weak var delegate: EditClassicProfileDelegate?

    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: BSWCollectionViewFlowLayout())
    var flowLayout: UICollectionViewFlowLayout {
        get {
            return collectionView.collectionViewLayout as! BSWCollectionViewFlowLayout
        }
    }
    
    private var collectionViewDataSource: CollectionViewStatefulDataSource<PhotoUploadViewModel, PhotoCollectionViewCell>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        setupTableView()
        setupCollectionView()
        
        //Fuck you UIKit!
        view.setNeedsLayout()
        view.layoutIfNeeded()
        flowLayout.invalidateLayout()
    }
    
    //MARK:- Private
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        constrain(tableView) { tableView in
            tableView.edges == tableView.superview!.edges
        }
    }
    
    private func setupCollectionView() {

        /// Layout the collectionView
        tableView.tableHeaderView = collectionView
        constrain(tableView, collectionView) { tableView, collectionView in
            collectionView.width == tableView.width
            collectionView.height == tableView.width * (2 / 3)
        }
        
        /// Prepare the FlowLayout
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        /// Prepare the Gesture Recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoReordering))
        collectionView.addGestureRecognizer(longPressGesture)
        
        /// Prepare the collectionViewDataSource
        collectionViewDataSource = CollectionViewStatefulDataSource<PhotoUploadViewModel, PhotoCollectionViewCell>(
            state: .Loaded(data: createPhotoArray(profile.photos)),
            collectionView: collectionView,
            mapper: { return $0 }
        )
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
    }
    
    private func createPhotoArray(photos: [Photo]) -> [PhotoUploadViewModel] {
        let photosAsUploadPhotos = photos.map { return PhotoUploadViewModel.Filled($0)  }
        let missingPhotos = Constants.MaxPhotosCount - photosAsUploadPhotos.count
        let emptyPhotos = [PhotoUploadViewModel](count:missingPhotos, repeatedValue: PhotoUploadViewModel.Empty)
        return photosAsUploadPhotos + emptyPhotos
    }
}

extension EditClassicProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension EditClassicProfileViewController: UICollectionViewDelegateFlowLayout {

    public func handlePhotoReordering(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
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
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard CGRectGetWidth(self.collectionView.frame) != 0  else {
            return CGSizeZero
        }
        guard CGRectGetHeight(self.collectionView.frame) != 0  else {
            return CGSizeZero
        }
        
        return CGSizeMake(
            CGRectGetWidth(self.collectionView.frame) / 3,
            CGRectGetHeight(self.collectionView.frame) / 2
        )
    }
    
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.profile = profile.movePhotoAtIndex(sourceIndexPath.item, toIndex: destinationIndexPath.item)
        self.delegate?.didChangePhotoArrangement(fromIndex: UInt(sourceIndexPath.item), toIndex: UInt(destinationIndexPath.item))
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didRequestAddPhoto(atIndex: UInt(indexPath.item))
    }
}

enum PhotoUploadViewModel {
    case Empty
    case Uploading(NSProgress, UIImage)
    case Filled(Photo)
}

private class PhotoCollectionViewCell: UICollectionViewCell, ViewModelReusable {
 
    enum Constants {
        static let CellPadding = CGFloat(5)
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(imageView)
        imageView.backgroundColor = .whiteColor()
        constrain(imageView) { imageView in
            imageView.edges == inset(imageView.superview!.edges, Constants.CellPadding)
        }
    }
    
    func configureFor(viewModel viewModel: PhotoUploadViewModel) {
        switch viewModel {
        case .Empty:
            imageView.image = UIImage.templateImage(.Plus)
        case .Uploading(_, _):
            break
        case .Filled(let photo):
            imageView.bsw_setPhoto(photo)
        }
    }
}
