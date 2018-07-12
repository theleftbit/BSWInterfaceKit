
import UIKit

// MARK: Private classes

open class PhotoPickerTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    
    let photosCollectionView = ProfilePhotoPickerCollectionView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        contentView.addSubview(photosCollectionView)
        photosCollectionView.pinToSuperview()
        photosCollectionView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: ProfilePhotoPickerCollectionView.Constants.PhotoPickerRatio).isActive = true
    }
    
    open func prepareForPhotos(_ photos: [Photo], currentUploads: [(Progress, UIImage)] = []) {
        photosCollectionView.updatePhotos(
            PhotoPickerViewModel.createPhotoArray(
                photos,
                uploadingPhotos: currentUploads,
                maxPhotos: ProfilePhotoPickerCollectionView.Constants.MaxPhotosCount
            )
        )
    }
    
    open func setPresentingViewController(_ vc: UIViewController, profilePhotoDelegate: ProfilePhotoPickerDelegate) {
        photosCollectionView.presentingViewController = vc
        photosCollectionView.profilePhotoDelegate = profilePhotoDelegate
    }
}
