//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography
import Deferred
import BSWFoundation

public enum ClassicProfileEditKind {
    case NonEditable
    case Editable(UIBarButtonItem)
}

public class ClassicProfileViewController: ScrollableStackViewController, AsyncViewModelPresenter {
    
    public var dataProvider: Future<Result<ClassicProfileViewModel>>!
    public var editKind: ClassicProfileEditKind = .NonEditable
    let photoGallery = PhotoGalleryView()
    let titleLabel = UILabel.unlimitedLinesLabel()
    let detailsLabel = UILabel.unlimitedLinesLabel()
    let bioLabel = UILabel.unlimitedLinesLabel()
    let separatorView: UIView = {
        let view = UIView()
        constrain(view) { view in
            view.height == 1
            view.width == 30
        }
        view.backgroundColor = UIColor.lightGrayColor()
        return view
    }()
    
    var navBarBehaviour: NavBarTransparentBehavior?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        //This is set to false in order to layout the image below the transparent navBar
        automaticallyAdjustsScrollViewInsets = false
        if let tabBar = tabBarController?.tabBar {
            scrollableStackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(tabBar.frame), right: 0)
        }
        
        //This is the transparent navBar behaviour
        if let navBar = self.navigationController?.navigationBar {
            navBarBehaviour = NavBarTransparentBehavior(navBar: navBar, scrollView: scrollableStackView)
        }
        
        //Add the photoGallery
        photoGallery.delegate = self
        scrollableStackView.addArrangedSubview(photoGallery)
        constrain(photoGallery, scrollableStackView) { photoGallery, scrollableStackView in
            photoGallery.height == 280
            photoGallery.width == scrollableStackView.width
        }
        
        let layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        scrollableStackView.addArrangedSubview(titleLabel, layoutMargins: layoutMargins)
        scrollableStackView.addArrangedSubview(detailsLabel, layoutMargins: layoutMargins)
        scrollableStackView.addArrangedSubview(separatorView, layoutMargins: layoutMargins)
        scrollableStackView.addArrangedSubview(bioLabel, layoutMargins: layoutMargins)
        
        //Add the rightBarButtonItem
        switch editKind {
        case .Editable(let barButton):
            navigationItem.rightBarButtonItem = barButton
        default:
            break
        }
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
        
        guard let viewModel = dataProvider.peek()?.value else { return }
        
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
