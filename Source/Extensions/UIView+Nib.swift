//
//  Created by Pierluigi Cifani on 22/04/16.
//

import UIKit

public extension UIView {
    
    public class func instantiateFromNib<T: UIView>(viewType: T.Type) -> T? {
        let className = NSStringFromClass(viewType).componentsSeparatedByString(".").last!
        return NSBundle.mainBundle().loadNibNamed(className, owner: nil, options: nil).first as? T
    }
    
    public class func instantiateFromNib() -> Self? {
        return instantiateFromNib(self)
    }
}

