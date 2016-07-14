//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

protocol EditClassicProfileDelegate: EditClassicProfilePhotoDelegate {
    
}

protocol EditClassicProfilePhotoDelegate: class {
    func didChangePhotoArrangement(fromIndex index: UInt, toIndex: UInt)
    func didDeletePhoto(atIndex index: UInt)
    func didAddPhoto(photo: Photo, atIndex: UInt)
}

public class EditClassicProfileViewController: UIViewController {

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
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var flowLayout: UICollectionViewFlowLayout {
        get {
            return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        constrain(tableView) { tableView in
            tableView.edges == inset(tableView.superview!.edges, 0)
        }
        
        tableView.tableHeaderView = collectionView
        constrain(tableView, collectionView) { tableView, collectionView in
            collectionView.width == tableView.width
            collectionView.height == CGFloat(250)
        }
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard self.traitCollection.horizontalSizeClass != .Regular else {
            fatalError("We're not ready for this")
        }
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
