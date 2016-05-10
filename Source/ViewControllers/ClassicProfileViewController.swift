//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public typealias ProfileEditionHandler = Void -> Void

public enum ClassicProfileEditKind {
    case NonEditable
    case Editable(UIBarButtonItem, ProfileEditionHandler)
}

public protocol ClassicProfileViewModel {
    var photos: [Photo] { get }
    var titleInfo: NSAttributedString { get }
    var detailsInfo: NSAttributedString { get }
    var extraInfo: [NSAttributedString] { get }
    var editKind: ClassicProfileEditKind { get }
}

public class ClassicProfileViewController: ScrollableStackViewController, ViewModelSettable {
    
    public var viewModel: ClassicProfileViewModel? {
        didSet {
            if let viewModel = viewModel {
                configureFor(viewModel: viewModel)
            }
        }
    }
    
    let photoGallery = PhotoGalleryView()
    let titleLabel = UILabel()
    let detailsLabel = UILabel()
    let bioLabel = UILabel()

    var navBarBehaviour: NavBarTransparentBehavior?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //This is set to false in order to layout the image below the transparent navBar
        automaticallyAdjustsScrollViewInsets = false
        
        //This is the transparent navBar behaviour
        if let navBar = self.navigationController?.navigationBar {
            navBarBehaviour = NavBarTransparentBehavior(navBar: navBar, scrollView: scrollableStackView)
        }
        
        //Add the photoGallery
        photoGallery.delegate = self
        scrollableStackView.addArrangedSubview(photoGallery)
        constrain(photoGallery) { photoGallery in
            photoGallery.height == 280
        }
        
        let layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        scrollableStackView.addArrangedSubview(titleLabel, layoutMargins: layoutMargins)
        scrollableStackView.addArrangedSubview(detailsLabel, layoutMargins: layoutMargins)
        scrollableStackView.addArrangedSubview(bioLabel, layoutMargins: layoutMargins)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navBarBehaviour?.setNavBar(toState: .Regular)
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK:- Private
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) -> Void {
        photoGallery.photos = viewModel.photos
        titleLabel.attributedText = viewModel.titleInfo
        detailsLabel.attributedText = viewModel.detailsInfo
        bioLabel.attributedText = viewModel.extraInfo.first
    }
}

//MARK:- PhotoGalleryViewDelegate

extension ClassicProfileViewController: PhotoGalleryViewDelegate {
    public func didTapPhotoAt(index index: UInt, fromView: UIView) {
        
        guard let viewModel = viewModel else { return }
        
        let gallery = PhotoGalleryViewController(
            photos: viewModel.photos,
            presentFromView: fromView,
            initialPageIndex: index,
            allowShare: false
        )
        gallery.delegate = self
        presentViewController(gallery, animated: true, completion: nil)
    }
}

//MARK:- PhotoGalleryViewControllerDelegate

extension ClassicProfileViewController: PhotoGalleryViewControllerDelegate {
    public func photoGalleryController(photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: UInt) {
        photoGallery.scrollToPhoto(atIndex: index)
        dismissViewControllerAnimated(true, completion: nil)
    }
}