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
    
    public var isEditable: Bool {
        switch self {
        case .Editable(_):
            return true
        default:
            return false
        }
    }
}

public class ClassicProfileViewController: ScrollableStackViewController, AsyncViewModelPresenter {
    
    enum Constants {
        static let SeparatorSize = CGSize(width: 30, height: 1)
        static let LayoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let PhotoGallerySize = CGFloat(250)
    }
    
    public var dataProvider: Future<Result<ClassicProfileViewModel>>! {
        didSet {
            scrollableStackView.alpha = 0
            view.addSubview(loadingView)
            loadingView.centerInSuperview()
            
            dataProvider.uponMainQueue { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.scrollableStackView.alpha = 1
                strongSelf.loadingView.removeFromSuperview()
            }
        }
    }
    public var editKind: ClassicProfileEditKind = .NonEditable
    private lazy var loadingView = LoadingView()
    private let photoGallery = PhotoGalleryView()
    private let titleLabel = UILabel.unlimitedLinesLabel()
    private let detailsLabel = UILabel.unlimitedLinesLabel()
    private let extraDetailsLabel = UILabel.unlimitedLinesLabel()
    private let separatorView: UIView = {
        let view = UIView()
        constrain(view) { view in
            view.height == Constants.SeparatorSize.height
            view.width == Constants.SeparatorSize.width
        }
        view.backgroundColor = UIColor.lightGrayColor()
        return view
    }()
    
    private var navBarBehaviour: NavBarTransparentBehavior?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = dataProvider else { fatalError() }
        
        view.backgroundColor = UIColor.whiteColor()

        //This is set to false in order to layout the image below the transparent navBar
        automaticallyAdjustsScrollViewInsets = false
        if let tabBar = tabBarController?.tabBar {
            scrollableStackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(tabBar.frame), right: 0)
        }
        
        //Add the photoGallery
        photoGallery.delegate = self
        scrollableStackView.addArrangedSubview(photoGallery)
        constrain(photoGallery, scrollableStackView) { photoGallery, scrollableStackView in
            photoGallery.height == Constants.PhotoGallerySize
            photoGallery.width == scrollableStackView.width
        }
        
        scrollableStackView.addArrangedSubview(titleLabel, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(detailsLabel, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(separatorView, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(extraDetailsLabel, layoutMargins: Constants.LayoutMargins)
        
        //Add the rightBarButtonItem
        switch editKind {
        case .Editable(let barButton):
            navigationItem.rightBarButtonItem = barButton
        default:
            break
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //This is the transparent navBar behaviour
        if let navBar = self.navigationController?.navigationBar {
            navBarBehaviour = NavBarTransparentBehavior(navBar: navBar, scrollView: scrollableStackView)
        }
        
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
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) {
        
        photoGallery.photos = viewModel.photos
        titleLabel.attributedText = viewModel.titleInfo
        detailsLabel.attributedText = viewModel.detailsInfo
        extraDetailsLabel.attributedText = viewModel.extraInfo.joinedStrings()
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
