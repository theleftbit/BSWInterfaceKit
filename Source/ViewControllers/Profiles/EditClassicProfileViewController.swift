//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography
import BSWFoundation

public protocol EditClassicProfileDelegate: EditClassicProfilePhotoDelegate {
    
}

public protocol EditClassicProfilePhotoDelegate: class {
    func didChangePhotoArrangement(fromIndex index: Int, toIndex: Int)
    func didRequestDeletePhoto(photoIndex: Int)
    func didRequestAddPhoto(imageURL url: NSURL) -> NSProgress?
}

public class EditClassicProfileViewController: UIViewController, ViewModelConfigurable {

    enum Constants {
        static let PhotoPickerCellReuseID = "PhotoPickerCellReuseID"
        static let PhotoPickerRatio: CGFloat = (2 / 3)
    }
    
    enum Sections: Int {
        case PhotoPicker = 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(profile: ClassicProfileViewModel) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) {
        tableView.reloadData()
    }
    
    var profile: ClassicProfileViewModel
    public weak var delegate: EditClassicProfileDelegate?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    //MARK:- Private
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.registerClass(PhotoPickerTableViewCell.self, forCellReuseIdentifier: Constants.PhotoPickerCellReuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension EditClassicProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { return 0 }
        switch section {
        case .PhotoPicker:
            return 1
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .PhotoPicker:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PhotoPickerCellReuseID) as? PhotoPickerTableViewCell else { fatalError()}
            cell.prepareForPhotos(self.profile.photos)
            cell.setPresentingViewController(self, profilePhotoDelegate: self)
            return cell
        }
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Sections(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .PhotoPicker:
            return CGRectGetWidth(tableView.frame) * Constants.PhotoPickerRatio
        }
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        // Why? http://stackoverflow.com/a/23955420/1152289

        guard let section = Sections(rawValue: section) else { fatalError() }
        switch section {
        case .PhotoPicker:
            return CGFloat.min
        default:
            return 0
        }
    }
}

// MARK: ProfilePhotoPickerDelegate

extension EditClassicProfileViewController: ProfilePhotoPickerDelegate {
    public func userAddedProfilePicture(url: NSURL) -> (NSProgress, UIImage)? {
        guard let data = NSData(contentsOfURL: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        guard let delegate = self.delegate else { return nil }
        guard let progress = delegate.didRequestAddPhoto(imageURL: url) else { return nil }
        PhotoUploadObserver.observer.observeProgress(progress, forImage: image)
        return (progress, image)
    }
    
    public func userDeletedProfilePictureAtIndex(index: Int) {
        self.delegate?.didRequestDeletePhoto(index)
        self.profile = profile.removePhotoAtIndex(index)
    }
    
    public func userChangedPhotoArrangement(fromIndex index: Int, toIndex: Int) {
        self.delegate?.didChangePhotoArrangement(fromIndex: index, toIndex: toIndex)
    }
}

// MARK: Private classes

private class PhotoPickerTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    
    let photosCollectionView = ProfilePhotoPickerCollectionView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(photosCollectionView)
        photosCollectionView.fillSuperview()
    }
    
    public func prepareForPhotos(photos: [Photo]) {
        photosCollectionView.updatePhotos(
            PhotoPickerViewModel.createPhotoArray(
                photos,
                uploadingPhotos: PhotoUploadObserver.observer.currentUploads,
                maxPhotos: ProfilePhotoPickerCollectionView.Constants.MaxPhotosCount
            )
        )
    }
    
    public func setPresentingViewController(vc: UIViewController, profilePhotoDelegate: ProfilePhotoPickerDelegate) {
        photosCollectionView.presentingViewController = vc
        photosCollectionView.profilePhotoDelegate = profilePhotoDelegate
    }
}

private class PhotoUploadObserver {
    
    static let observer = PhotoUploadObserver()
    private var currentUploads:[(NSProgress, UIImage)] = []
    
    func observeProgress(progress: NSProgress, forImage image: UIImage) {
        currentUploads.append((progress, image))
    }
}
