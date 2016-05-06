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

public protocol ClassicProfilePictureViewModel {
    var pictureURL: NSURL { get }
    var averageColor: UIColor { get }
}

public protocol ClassicProfileViewModel {
    var pictures: [PhotoGalleryItem] { get }
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        photoGallery = PhotoGalleryView(items: SamplePhoto.samplePhotos())
        photoGallery.heightAnchor.constraintEqualToConstant(280)
        scrollableStackView.stackView.addArrangedSubview(photoGallery)
    }
    
    //MARK:- Private
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) -> Void {
        
    }
}

struct SamplePhoto: PhotoGalleryItem {
    let url: NSURL
    let averageColor: UIColor
    
    static func samplePhotos() -> [PhotoGalleryItem] {
        let photo1 = SamplePhoto(url: NSURL(string: "http://e2.365dm.com/15/09/768x432/alessandro-del-piero-juventus-serie-a_3351343.jpg?20150915122301")!, averageColor: UIColor.randomColor())
        let photo2 = SamplePhoto(url: NSURL(string: "http://images1.fanpop.com/images/photos/2000000/Old-Golden-Days-alessandro-del-piero-2098417-600-705.jpg")!, averageColor: UIColor.randomColor())
        let photo3 = SamplePhoto(url: NSURL(string: "http://e0.365dm.com/14/05/768x432/Alessandro-del-Piero-italy-2002_3144508.jpg?20140520095830")!, averageColor: UIColor.randomColor())
        let photo4 = SamplePhoto(url: NSURL(string: "http://www.goal.com/en/news/1717/editorial/2014/11/09/5886501/debate-who-was-greater-del-piero-or-totti")!, averageColor: UIColor.randomColor())
        return [photo1, photo2, photo3, photo4]
    }
}
