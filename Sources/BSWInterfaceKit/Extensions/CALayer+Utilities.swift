//
//  Created by Pierluigi Cifani on 11/07/2018.
//

#if canImport(UIKit)

import UIKit

// https://medium.com/swifty-tim/views-with-rounded-corners-and-shadows-c3adc0085182

public extension CALayer {
    
    func addShadow(opacity: CGFloat = 0.5, shadowRadius: CGFloat = 10, offset: CGSize = .zero) {
        self.shadowOffset = offset
        self.shadowOpacity = Float(opacity)
        self.shadowRadius = shadowRadius
        self.shadowColor = UIColor.black.cgColor
        self.masksToBounds = false
        if cornerRadius != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        if shadowOpacity != 0 {
            addShadowWithRoundedCorners()
        }
    }
    
    private func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "Constants.contentLayerName" {
                
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "Constants.contentLayerName"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}

#endif
