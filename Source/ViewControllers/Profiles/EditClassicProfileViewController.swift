//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class EditClassicProfileViewController: UIViewController {
    public init(profile: ClassicProfileViewModel) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
