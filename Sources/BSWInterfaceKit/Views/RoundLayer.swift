//
//  Created by Pierluigi Cifani on 26/03/2019.
//  Copyright © 2019 TheLeftBit SL. All rights reserved.
//

import UIKit
class RoundLayer: CALayer {
    
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
    
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var cornerRadius: CGFloat {
        get {
            return self.frame.size.width/2
        } set {
            fatalError()
        }
    }
}
