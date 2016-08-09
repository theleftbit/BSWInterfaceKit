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
    
    func isFilled() -> Bool {
        switch self {
        case .Filled(_):
            return true
        default:
            return false
        }
    }
    
    static func createPhotoArray(photos: [Photo], uploadingPhotos: [(NSProgress, UIImage)] = [], maxPhotos: Int) -> [PhotoPickerViewModel] {
        let photosAsUploadPhotos = photos.map { return PhotoPickerViewModel.Filled($0)  }
        let uploadingPhotos = uploadingPhotos.map { return PhotoPickerViewModel.Uploading($0)  }
        let missingPhotos = maxPhotos - photosAsUploadPhotos.count - uploadingPhotos.count
        let emptyPhotos = [PhotoPickerViewModel](count:missingPhotos, repeatedValue: PhotoPickerViewModel.Empty)
        return photosAsUploadPhotos + uploadingPhotos + emptyPhotos
    }
}

public protocol ProfilePhotoPickerDelegate: class {
    func userAddedProfilePicture(url: NSURL)
    func userDeletedProfilePictureAtIndex(index: Int)
    func userChangedPhotoArrangement(fromIndex index: Int, toIndex: Int)
}

public class ProfilePhotoPickerCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, ProfilePhotoPickerCollectionViewCellDelegate {
    
    enum Constants {
        static let MaxPhotosCount = 6
    }
    
    private var photosDataSource: CollectionViewStatefulDataSource<PhotoPickerViewModel, ProfilePhotoPickerCollectionViewCell>!
    private lazy var mediaPicker: MediaPickerBehavior = {
        return MediaPickerBehavior(presentingVC: self.presentingViewController!)
    }()
    
    public private(set) var photos: [PhotoPickerViewModel]
    public weak var presentingViewController: UIViewController?
    public weak var profilePhotoDelegate: ProfilePhotoPickerDelegate?

    public init(photos: [PhotoPickerViewModel] = []) {
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
                guard let fromPhoto = self.photos[safe:indexPath.item] where fromPhoto.isFilled()  else { return false }
                return true
            },
            moveItemAtIndexPath: { (from, to) in
                //If the destination is not valid, transition back
                guard let destinationPhoto = self.photos[safe:to.item] where destinationPhoto.isFilled() else {
                    self.photosDataSource.performEditActions([.Move(fromIndexPath: to, toIndexPath: from)])
                    return
                }
                
                self.photos.moveItem(fromIndex: from.item, toIndex: to.item)
                self.profilePhotoDelegate?.userChangedPhotoArrangement(fromIndex: from.item, toIndex: to.item)
            }
        )
        
        /// Prepare the collectionViewDataSource
        photosDataSource = CollectionViewStatefulDataSource(
            state: .Loaded(data: photos),
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
    
    public func updatePhotos(photos: [PhotoPickerViewModel]) {
        self.photos = photos
        photosDataSource.updateState(.Loaded(data: photos))
    }
    
    private func userAddedProfilePicture(url: NSURL?) {
        guard let url = url else { return }
        profilePhotoDelegate?.userAddedProfilePicture(url)
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
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ProfilePhotoPickerCollectionViewCell else { return }
        cell.cellDelegate = self
    }
    
    // MARK: ProfilePhotoPickerCollectionViewCellDelegate

    private func didTapOnProfilePhotoCell(cell: ProfilePhotoPickerCollectionViewCell) {
        guard let index = indexPathForCell(cell) else { return }
        guard let photo = photosDataSource.state.data?[safe: index.item] else { return }
        guard let presentingVC = presentingViewController else { return }
        
        let _alertController: UIAlertController? = {
            switch photo {
            case .Empty:
                let alert = UIAlertController(title: localizableString(.AddPhotoTitle), message: nil, preferredStyle: .ActionSheet)
                
                let albumAction = UIAlertAction(title: localizableString(.PhotoAlbum), style: .Default) { _ in
                    self.mediaPicker.getMedia(source: .PhotoAlbum, handler: self.userAddedProfilePicture)
                }

                let cameraAction = UIAlertAction(title: localizableString(.Camera), style: .Default) { _ in
                    self.mediaPicker.getMedia(source: .Camera, handler: self.userAddedProfilePicture)
                }
                
                let dismissAction = UIAlertAction(title: localizableString(.Dismiss), style: .Cancel) { _ in
                    
                }

                alert.addAction(albumAction)
                alert.addAction(cameraAction)
                alert.addAction(dismissAction)
                return alert
            case .Filled(let photo):
                let alert = UIAlertController(title: localizableString(.ConfirmDeleteTitle), message: nil, preferredStyle: .Alert)
                
                let yesAction = UIAlertAction(title: localizableString(.Yes), style: .Destructive) { _ in
                    self.profilePhotoDelegate?.userDeletedProfilePictureAtIndex(index.item)
                    
                    let actions: [CollectionViewEditActionKind<PhotoPickerViewModel>] = [
                        .Insert(item: PhotoPickerViewModel.Empty, atIndexPath: NSIndexPath(forItem: Constants.MaxPhotosCount - 1, inSection: 0)),
                        .Remove(fromIndexPath: index)
                    ]

                    self.photosDataSource.performEditActions(actions)
                }
                
                let noAction = UIAlertAction(title: localizableString(.No), style: .Default) { _ in
                    
                }
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                return alert
            case .Uploading(_, _):
                return nil
            }
        }()
        
        guard let alertController = _alertController else { return }
        presentingVC.presentViewController(alertController, animated: true, completion: nil)
    }
}

private protocol ProfilePhotoPickerCollectionViewCellDelegate: class {
    func didTapOnProfilePhotoCell(cell: ProfilePhotoPickerCollectionViewCell)
}

private class ProfilePhotoPickerCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    enum Constants {
        static let CellPadding = CGFloat(5)
        static let AccesorySize = CGFloat(20)
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()

    let accesoryView = UIButton(type: .Custom)
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    var cellDelegate: ProfilePhotoPickerCollectionViewCellDelegate?
    
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
        contentView.addSubview(spinner)
        imageView.addSubview(accesoryView)
        imageView.backgroundColor = .whiteColor()
        imageView.roundCorners()
        imageView.userInteractionEnabled = true
        spinner.hidesWhenStopped = true
        constrain(imageView, accesoryView, spinner) { imageView, accesoryView, spinner in
            imageView.edges == inset(imageView.superview!.edges, Constants.CellPadding)
            accesoryView.bottom == imageView.bottom - Constants.CellPadding
            accesoryView.right == imageView.right - Constants.CellPadding
            accesoryView.width == Constants.AccesorySize
            accesoryView.height == Constants.AccesorySize
            spinner.centerX == spinner.superview!.centerX
            spinner.centerY == spinner.superview!.centerY
        }
    }
    
    private override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = .whiteColor()
        accesoryView.removeTarget(self, action: #selector(onAccesoryTapped), forControlEvents: .TouchDown)
    }
    
    func configureFor(viewModel viewModel: PhotoPickerViewModel) {
        
        accesoryView.addTarget(self, action: #selector(onAccesoryTapped), forControlEvents: .TouchDown)

        switch viewModel {
        case .Empty:
            spinner.stopAnimating()
            imageView.image = nil
            imageView.backgroundColor = .lightGrayColor()
            imageView.removeBlurImage()
            accesoryView.setImage(UIImage.templateImage(.PlusRound), forState: .Normal)
        case .Uploading(_, let image):
            spinner.startAnimating()
            imageView.image = image
            imageView.makeBlurImage()
            accesoryView.setImage(nil, forState: .Normal)
        case .Filled(let photo):
            spinner.stopAnimating()
            imageView.bsw_setPhoto(photo)
            imageView.removeBlurImage()
            accesoryView.setImage(UIImage.templateImage(.CancelRound), forState: .Normal)
        }
    }
    
    // MARK: IBActions
    
    @objc func onAccesoryTapped() {
        cellDelegate?.didTapOnProfilePhotoCell(self)
    }
}
