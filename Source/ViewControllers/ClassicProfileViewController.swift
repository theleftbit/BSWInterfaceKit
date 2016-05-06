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
    var pictureURL: [String] { get }
    var titleInfo: [NSAttributedString] { get }
    var detailInfo: [NSAttributedString] { get }
    var editKind: ClassicProfileEditKind { get }
}

class ClassicProfileViewController: UIViewController, ViewModelConfigurable {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- Private
    
    func configureFor(viewModel viewModel: ClassicProfileViewModel) -> Void {
        
    }
}
