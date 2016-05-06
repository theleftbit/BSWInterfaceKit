//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public protocol ViewModelConfigurable {
    associatedtype T
    func configureFor(viewModel viewModel: T) -> Void
}
