//
//  Created by Pierluigi Cifani on 04/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public enum PhotoPickerViewModel {
    case empty
    case uploading(Progress, UIImage)
    case filled(Photo)
    
    func isFilled() -> Bool {
        switch self {
        case .filled(_):
            return true
        default:
            return false
        }
    }

    func isUploading() -> Bool {
        switch self {
        case .uploading(_, _):
            return true
        default:
            return false
        }
    }

    func isEmpty() -> Bool {
        switch self {
        case .empty:
            return true
        default:
            return false
        }
    }

    static public func createPhotoArray(_ photos: [Photo], uploadingPhotos: [(Progress, UIImage)] = [], maxPhotos: Int) -> [PhotoPickerViewModel] {
        let photosAsUploadPhotos = photos.map { return PhotoPickerViewModel.filled($0) }
        let uploadingPhotos = uploadingPhotos.map { return PhotoPickerViewModel.uploading($0.0, $0.1) }
        let missingPhotos = maxPhotos - photosAsUploadPhotos.count - uploadingPhotos.count
        let emptyPhotos = [PhotoPickerViewModel](repeating: PhotoPickerViewModel.empty, count: missingPhotos)
        return photosAsUploadPhotos + uploadingPhotos + emptyPhotos
    }
}

public protocol ProfilePhotoPickerDelegate: class {
    func userAddedProfilePicture(_ url: URL, handler: @escaping (((Progress, UIImage)?) -> Void)) -> Void
    func userDeletedProfilePictureAtIndex(_ index: Int)
    func userChangedPhotoArrangement(fromIndex index: Int, toIndex: Int)
}

public class ProfilePhotoPickerCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, ProfilePhotoPickerCollectionViewCellDelegate {
    
    enum Constants {
        static let Columns = 3
        static let Rows = 2
        static var MaxPhotosCount: Int { return Columns * Rows }
        static var PhotoPickerRatio: CGFloat { return (CGFloat(Rows) / CGFloat(Columns)) }
    }
    
    private var photosDataSource: CollectionViewDataSource<ProfilePhotoPickerCollectionViewCell>!
    private lazy var mediaPicker: MediaPickerBehavior = {
        return MediaPickerBehavior()
    }()
    
    private var photos: [PhotoPickerViewModel] {
        get {
            return photosDataSource.data
        }
    }
    public weak var presentingViewController: UIViewController?
    public weak var profilePhotoDelegate: ProfilePhotoPickerDelegate?

    public init(photos: [PhotoPickerViewModel] = []) {

        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        /// Prepare the FlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        /// Add Reorder support
        let reorderSupport = CollectionViewReorderSupport<PhotoPickerViewModel>(
            canMoveItemAtIndexPath: { (indexPath) -> Bool in
                //Only allow moving of valid photos
                guard let fromPhoto = self.photos[safe:indexPath.item] , fromPhoto.isFilled()  else { return false }
                return true
            },
            didMoveItemAtIndexPath: { (from, to, movedItem) in
                
                //If the destination is not valid, transition back
                guard movedItem.isFilled() else {
                    self.photosDataSource.performEditActions([.move(fromIndexPath: to, toIndexPath: from)])
                    return
                }
                
                self.profilePhotoDelegate?.userChangedPhotoArrangement(fromIndex: (from as NSIndexPath).item, toIndex: (to as NSIndexPath).item)
            }
        )
        
        /// Prepare the collectionViewDataSource
        photosDataSource = CollectionViewDataSource(
            data: photos,
            collectionView: self
        )
        photosDataSource.reorderSupport = reorderSupport
        dataSource = photosDataSource
        delegate = self
        
        /// Don't move, please
        alwaysBounceVertical = false
        
        /// Make me customizable
        backgroundColor = .white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var flowLayout: UICollectionViewFlowLayout {
        get {
            return collectionViewLayout as! UICollectionViewFlowLayout
        }
    }
    
    public func updatePhotos(_ photos: [PhotoPickerViewModel]) {
        photosDataSource.updateData(photos)
    }

    private func userRequestedProfilePictureUpload(fromSource source: MediaPickerBehavior.Source) {
        guard let presentingVC = self.presentingViewController else {
            return
        }
        guard let vc = self.mediaPicker.getMedia(source: source, handler: self.userAddedProfilePicture) else {
            return
        }
        presentingVC.present(vc, animated: true, completion: nil)
    }
    
    private func userAddedProfilePicture(_ url: URL?) {
        let photos = self.photosDataSource.data
        guard let url = url else { return }
        guard let index = photos.firstIndex(where: { return $0.isEmpty() }) else { return }
        profilePhotoDelegate?.userAddedProfilePicture(url) {
            guard let tuple = $0 else { return }
            let firstEmptyIndexPath = IndexPath(item: index, section: 0)
            let action: CollectionViewEditActionKind<PhotoPickerViewModel> = .reload(item: .uploading(tuple.0, tuple.1), indexPath: firstEmptyIndexPath)
            self.photosDataSource.performEditActions([action])
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard self.frame.width != 0, self.frame.height != 0  else {
            return .zero
        }
        
        return CGSize(
            width: self.frame.width / CGFloat(Constants.Columns),
            height: self.frame.height / CGFloat(Constants.Rows)
        )
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ProfilePhotoPickerCollectionViewCell else { return }
        cell.cellDelegate = self
    }
    
    // MARK: ProfilePhotoPickerCollectionViewCellDelegate

    fileprivate func didTapOnProfilePhotoCell(_ cell: ProfilePhotoPickerCollectionViewCell) {
        guard let index = indexPath(for: cell) else { return }
        guard let photo = photosDataSource.data[safe: index.item] else { return }
        guard let presentingVC = presentingViewController else { return }
        
        let _alertController: UIAlertController? = {
            switch photo {
            case .empty:
                let alert = UIAlertController(title: localizableString(.addPhotoTitle), message: nil, preferredStyle: .actionSheet)
                
                let albumAction = UIAlertAction(title: localizableString(.photoAlbum), style: .default) { _ in
                    self.userRequestedProfilePictureUpload(fromSource: .photoAlbum)
                }

                let cameraAction = UIAlertAction(title: localizableString(.camera), style: .default) { _ in
                    self.userRequestedProfilePictureUpload(fromSource: .camera)
                }
                
                let dismissAction = UIAlertAction(title: localizableString(.dismiss), style: .cancel) { _ in
                    
                }

                alert.addAction(albumAction)
                alert.addAction(cameraAction)
                alert.addAction(dismissAction)
                return alert
            case .filled:
                let alert = UIAlertController(title: localizableString(.confirmDeleteTitle), message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: localizableString(.yes), style: .destructive) { _ in
                    self.profilePhotoDelegate?.userDeletedProfilePictureAtIndex((index as NSIndexPath).item)
                    
                    let actions: [CollectionViewEditActionKind<PhotoPickerViewModel>] = [
                        .insert(item: PhotoPickerViewModel.empty, atIndexPath: IndexPath(item: Constants.MaxPhotosCount - 1, section: 0)),
                        .remove(fromIndexPath: index)
                    ]

                    self.photosDataSource.performEditActions(actions)
                }
                
                let noAction = UIAlertAction(title: localizableString(.no), style: .default) { _ in
                    
                }
                
                alert.addAction(yesAction)
                alert.addAction(noAction)
                return alert
            case .uploading(_, _):
                return nil
            }
        }()
        
        guard let alertController = _alertController else { return }
        presentingVC.present(alertController, animated: true, completion: nil)
    }
}

private protocol ProfilePhotoPickerCollectionViewCellDelegate: class {
    func didTapOnProfilePhotoCell(_ cell: ProfilePhotoPickerCollectionViewCell)
}

private class ProfilePhotoPickerCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    enum Constants {
        static let CellPadding = CGFloat(5)
        static let AccesorySize = CGFloat(20)
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let accesoryView = UIButton(type: .custom)
    let spinner = UIActivityIndicatorView(style: .white)
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
        contentView.addAutolayoutSubview(imageView)
        contentView.addAutolayoutSubview(spinner)
        imageView.addAutolayoutSubview(accesoryView)
        imageView.backgroundColor = .white
        imageView.roundCorners()
        imageView.isUserInteractionEnabled = true
        spinner.hidesWhenStopped = true

        //Layout
        imageView.fillSuperview(withMargin: Constants.CellPadding)
        spinner.centerInSuperview()
        NSLayoutConstraint.activate([
            accesoryView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.CellPadding),
            accesoryView.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -Constants.CellPadding),
            accesoryView.widthAnchor.constraint(equalToConstant: Constants.AccesorySize),
            accesoryView.heightAnchor.constraint(equalToConstant: Constants.AccesorySize)
            ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = .white
        imageView.removeBlurEffect()
        accesoryView.removeTarget(self, action: #selector(onAccesoryTapped), for: .touchUpInside)
    }
    
    func configureFor(viewModel: PhotoPickerViewModel) {
        
        accesoryView.addTarget(self, action: #selector(onAccesoryTapped), for: .touchUpInside)

        switch viewModel {
        case .empty:
            spinner.stopAnimating()
            imageView.image = nil
            imageView.backgroundColor = .lightGray
            accesoryView.setImage(UIImage.templateImage(.plusRound), for: .normal)
        case .uploading(_, let image):
            spinner.startAnimating()
            imageView.image = image
            imageView.addBlurEffect()
            accesoryView.setImage(nil, for: .normal)
        case .filled(let photo):
            spinner.stopAnimating()
            imageView.setPhoto(photo)
            accesoryView.setImage(UIImage.templateImage(.cancelRound), for: .normal)
        }
    }
    
    // MARK: IBActions
    
    @objc func onAccesoryTapped() {
        cellDelegate?.didTapOnProfilePhotoCell(self)
    }
}
