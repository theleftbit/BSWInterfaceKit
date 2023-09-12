//
//  Created by Pierluigi Cifani on 09/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIImageView {
    
    @MainActor
    private struct AssociatedKeys {
        static var BlurEffectViewKey: UInt8 = 0
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

    public func addBlurEffect(_ blurEffect: UIBlurEffect = UIBlurEffect(style: .dark)) {
        self.blurEffectView = {
            let effectView = UIVisualEffectView(effect: blurEffect)
            self.addSubview(effectView)
            effectView.pinToSuperview()
            return effectView
        }()
    }
    
    @MainActor
    public func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
    
}
#endif
