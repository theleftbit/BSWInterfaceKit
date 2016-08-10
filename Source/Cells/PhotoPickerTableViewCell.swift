
import Cartography

// MARK: Private classes

public class PhotoPickerTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    
    let photosCollectionView = ProfilePhotoPickerCollectionView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(photosCollectionView)
        photosCollectionView.fillSuperview()
        constrain(photosCollectionView) { photosCollectionView in
            photosCollectionView.height == photosCollectionView.superview!.width * (ProfilePhotoPickerCollectionView.Constants.PhotoPickerRatio)
        }
    }
    
    public func prepareForPhotos(photos: [Photo], currentUploads: [(NSProgress, UIImage)] = []) {
        photosCollectionView.updatePhotos(
            PhotoPickerViewModel.createPhotoArray(
                photos,
                uploadingPhotos: currentUploads,
                maxPhotos: ProfilePhotoPickerCollectionView.Constants.MaxPhotosCount
            )
        )
    }
    
    public func setPresentingViewController(vc: UIViewController, profilePhotoDelegate: ProfilePhotoPickerDelegate) {
        photosCollectionView.presentingViewController = vc
        photosCollectionView.profilePhotoDelegate = profilePhotoDelegate
    }
}
