//
//  Created by Pierluigi Cifani on 04/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public enum PhotoPickerViewModel {
    case Empty
    case Uploading(NSProgress, UIImage)
    case Filled(Photo)
}

public class ProfilePhotoPickerCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
    
    enum Constants {
        static let MaxPhotosCount = 6
    }
    
    private var photosDataSource: CollectionViewStatefulDataSource<PhotoPickerViewModel, ProfilePhotoPickerCollectionViewCell>!
    
    public private(set) var photos: [Photo]
    
    public init(photos: [Photo] = []) {
        self.photos = photos
        super.init(frame: CGRectZero, collectionViewLayout: BSWCollectionViewFlowLayout())
        
        /// Prepare the FlowLayout
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        /// Add Reorder support
        let reorderSupport = CollectionViewReorderSupport(
            canMoveItemAtIndexPath: { (indexPath) -> Bool in
                //Only allow moving of valid photos
                guard let _ = self.photos[safe:indexPath.item] else { return false }
                return true
            },
            moveItemAtIndexPath: { (from, to) in
                //If the destination is not valid, transition back
                guard let _ = self.photos[safe:from.item], let _ = self.photos[safe:to.item] else {
                    self.photosDataSource.moveItem(fromIndexPath: to, toIndexPath: from)
                    return
                }
                
                self.photos.moveItem(fromIndex: from.item, toIndex: to.item)
            }
        )
        
        /// Prepare the collectionViewDataSource
        photosDataSource = CollectionViewStatefulDataSource(
            state: .Loaded(data: createPhotoArray(photos)),
            collectionView: self,
            reorderSupport: reorderSupport,
            mapper: { return $0 }
        )
        dataSource = photosDataSource
        delegate = self
        
        /// Don't move, please
        alwaysBounceVertical = false
        
        /// Make me customizable
        backgroundColor = .whiteColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var flowLayout: BSWCollectionViewFlowLayout {
        get {
            return collectionViewLayout as! BSWCollectionViewFlowLayout
        }
    }
    
    public func updatePhotos(photos: [Photo]) {
        self.photos = photos
        photosDataSource.updateState(.Loaded(data: createPhotoArray(photos)))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard CGRectGetWidth(self.frame) != 0  else {
            return CGSizeZero
        }
        guard CGRectGetHeight(self.frame) != 0  else {
            return CGSizeZero
        }
        
        return CGSizeMake(
            CGRectGetWidth(self.frame) / 3,
            CGRectGetHeight(self.frame) / 2
        )
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: Private
    
    private func createPhotoArray(photos: [Photo]) -> [PhotoPickerViewModel] {
        let photosAsUploadPhotos = photos.map { return PhotoPickerViewModel.Filled($0)  }
        let missingPhotos = Constants.MaxPhotosCount - photosAsUploadPhotos.count
        let emptyPhotos = [PhotoPickerViewModel](count:missingPhotos, repeatedValue: PhotoPickerViewModel.Empty)
        return photosAsUploadPhotos + emptyPhotos
    }

}

private class ProfilePhotoPickerCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    enum Constants {
        static let CellPadding = CGFloat(5)
        static let AccesorySize = CGFloat(20)
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()

    let accesoryView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
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
        imageView.addSubview(accesoryView)
        imageView.backgroundColor = .whiteColor()
        imageView.roundCorners()
        constrain(imageView, accesoryView) { imageView, accesoryView in
            imageView.edges == inset(imageView.superview!.edges, Constants.CellPadding)
            accesoryView.bottom == imageView.bottom - Constants.CellPadding
            accesoryView.right == imageView.right - Constants.CellPadding
            accesoryView.width == Constants.AccesorySize
            accesoryView.height == Constants.AccesorySize
        }
    }
    
    private override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = .whiteColor()
    }
    
    func configureFor(viewModel viewModel: PhotoPickerViewModel) {
        switch viewModel {
        case .Empty:
            imageView.image = nil
            imageView.backgroundColor = .lightGrayColor()
            accesoryView.image = UIImage.templateImage(.PlusRound)
        case .Uploading(_, _):
            break
        case .Filled(let photo):
            imageView.bsw_setPhoto(photo)
            accesoryView.image = UIImage.templateImage(.CancelRound)
        }
    }
}
