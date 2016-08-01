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

    struct Constants {
        static let MaxPhotosCount = 6
        static let PhotosCellSize = CGSizeMake(80, 80)
        static let PhotosCollectionViewHeight = CGFloat(250)
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
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var flowLayout: UICollectionViewFlowLayout {
        get {
            return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        }
    }
    
    private var collectionViewDataSource: CollectionViewStatefulDataSource<Photo, PhotoCollectionViewCell>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        setupTableView()
        setupCollectionView()
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard self.traitCollection.horizontalSizeClass != .Regular else {
            fatalError("We're not ready for this")
        }
    }
    
    //MARK:- Private
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        constrain(tableView) { tableView in
            tableView.edges == inset(tableView.superview!.edges, 0)
        }
    }
    
    private func setupCollectionView() {
        
        collectionViewDataSource = CollectionViewStatefulDataSource<Photo, PhotoCollectionViewCell>(
            state: .Loaded(data: profile.photos),
            collectionView: collectionView) { _ in
                return undefined()
        }
        
        flowLayout.scrollDirection = .Horizontal
        collectionView.dataSource = collectionViewDataSource
        collectionView.delegate = self
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoReordering))
        collectionView.addGestureRecognizer(longPressGesture)
        tableView.tableHeaderView = collectionView
        constrain(tableView, collectionView) { tableView, collectionView in
            collectionView.width == tableView.width
            collectionView.height == Constants.PhotosCollectionViewHeight
        }
    }
    
    private func createPhotoArray() -> PhotoCollectionViewModel {
        return undefined()
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
        return Constants.PhotosCellSize
    }
    
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.profile = profile.movePhotoAtIndex(sourceIndexPath.item, toIndex: destinationIndexPath.item)
        self.delegate?.didChangePhotoArrangement(fromIndex: UInt(sourceIndexPath.item), toIndex: UInt(destinationIndexPath.item))
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didRequestAddPhoto(atIndex: UInt(indexPath.item))
    }
}

private struct PhotoCollectionViewModel {
    
    enum State {
        case Empty
        case Uploading(NSProgress, UIImage)
        case Filled(Photo)
    }
    
    let state: State
}

private class PhotoCollectionViewCell: UICollectionViewCell, ViewModelReusable {
 
    func configureFor(viewModel viewModel: PhotoCollectionViewModel) {
    
    }
}
