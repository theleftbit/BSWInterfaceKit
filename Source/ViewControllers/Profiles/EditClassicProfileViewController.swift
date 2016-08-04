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
    weak var delegate: EditClassicProfileDelegate?

    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
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
        photosCollectionView.updatePhotos(photos)
    }
}
