//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

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
            navBarBehaviour = NavBarTransparentBehavior(navBar: navBar, scrollView: scrollableStackView.scrollView)
        }
        
        photoGallery = PhotoGalleryView(photos: Photo.samplePhotos())
        photoGallery.delegate = self
        photoGallery.heightAnchor.constraintEqualToConstant(280)
        scrollableStackView.stackView.addArrangedSubview(photoGallery)
        
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
    public func didTapPhotoAt(index index: Int, fromView: UIView) {
        
    }
}
