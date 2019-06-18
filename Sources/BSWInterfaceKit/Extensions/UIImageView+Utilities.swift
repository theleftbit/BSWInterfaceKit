//
//  Created by Pierluigi Cifani on 09/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import UIKit

extension UIImageView {
    
    private struct AssociatedKeys {
        static var BlurEffectViewKey = "BlurEffectViewKey"
    }

    public var blurEffectView: UIVisualEffectView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.BlurEffectViewKey) as? UIVisualEffectView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.BlurEffectViewKey,
                    newValue as UIVisualEffectView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }

    public func addBlurEffect() {
        self.blurEffectView = {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            self.addSubview(effectView)
            effectView.pinToSuperview()
            return effectView
        }()
    }
    
    public func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
    
}
