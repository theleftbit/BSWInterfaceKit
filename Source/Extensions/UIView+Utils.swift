//
//  Created by Pierluigi Cifani on 2/22/16.
//  Copyright © 2016 Wallapop SL. All rights reserved.
//

import BSWFoundation
import Cartography

extension UIView {
    
    public func findSubviewWithTag(tag: NSInteger) -> UIView? {
        return subviews.find({return $0.tag == tag})
    }
    
    public func removeSubviewWithTag(tag: NSInteger) {
        findSubviewWithTag(tag)?.removeFromSuperview()
    }
    
    public func roundCorners() {
        let cornerRadius = CGFloat(10.0)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    public func getColorFromPoint(point: CGPoint) -> UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGBitmapContextCreate(&pixelData, 1, 1, 8, 4, colorSpace, bitmapInfo)
        CGContextTranslateCTM(context, -point.x, -point.y);
        self.layer.renderInContext(context!)
        
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    public func fillSuperview(edges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        constrain(self) { view in
            view.edges == inset(view.superview!.edges, edges.top, edges.left, edges.bottom, edges.right)
        }
    }
}
