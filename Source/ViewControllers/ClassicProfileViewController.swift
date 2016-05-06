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

public class ClassicProfileViewController: ScrollableStackViewController, ViewModelSettable {
    
    public var viewModel: ClassicProfileViewModel? {
        didSet {
            if let viewModel = viewModel {
                configureFor(viewModel: viewModel)
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:- Private
    
    public func configureFor(viewModel viewModel: ClassicProfileViewModel) -> Void {
        
    }
}
