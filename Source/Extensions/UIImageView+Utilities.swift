//
//  Created by Pierluigi Cifani on 09/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView {
    
    private struct AssociatedKeys {
        static var BlurEffectViewKey = "BlurEffectViewKey"
    }

    var blurEffectView: UIVisualEffectView? {
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

    func makeBlurImage() {
        self.blurEffectView = {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            self.addSubview(effectView)
            effectView.fillSuperview()
            return effectView
        }()
    }
    
    func removeBlurImage() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
    
}
