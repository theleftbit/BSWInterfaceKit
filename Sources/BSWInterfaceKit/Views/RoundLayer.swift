//
//  Created by Pierluigi Cifani on 26/03/2019.
//  Copyright © 2019 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit.CALayer)

import UIKit

/// This `CALayer` subclass will ensure that the `UIView` backed by this layer will always be rounded.
public class RoundLayer: CALayer {
    
    override init() {
        super.init()
        masksToBounds = true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        masksToBounds = true
    }
    
    override public var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var cornerRadius: CGFloat {
        get {
            return self.frame.size.width/2
        } set {
            fatalError()
        }
    }
}

#endif
