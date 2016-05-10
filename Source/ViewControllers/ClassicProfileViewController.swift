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
    var titleInfo: [NSAttributedString] { get }
    var detailInfo: [NSAttributedString] { get }
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
    
    var photoGallery: PhotoGalleryView!
    var navBarBehaviour: NavBarTransparentBehavior?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        if let navBar = self.navigationController?.navigationBar {
            navBarBehaviour = NavBarTransparentBehavior(navBar: navBar, scrollView: scrollableStackView)
        }
        
        photoGallery = PhotoGalleryView(photos: Photo.samplePhotos())
        photoGallery.delegate = self
        scrollableStackView.stackView.addArrangedSubview(photoGallery)
        constrain(photoGallery) { photoGallery in
            photoGallery.height == 280
        }
        
        for i in 1...100 {
            let label = UILabel()
            label.text = "Button"
            label.backgroundColor = UIColor.randomColor()
            scrollableStackView.stackView.addArrangedSubview(label)
        }
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navBarBehaviour?.setNavBar(toState: .Regular)
    }
    
    //MARK:- Private
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) -> Void {
        
    }
}

//MARK:- PhotoGalleryViewDelegate

extension ClassicProfileViewController: PhotoGalleryViewDelegate {
    public func didTapPhotoAt(index index: UInt, fromView: UIView) {
        let gallery = PhotoGalleryViewController(
            photos: Photo.samplePhotos(),
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