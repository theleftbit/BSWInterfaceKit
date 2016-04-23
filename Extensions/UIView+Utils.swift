//
//  Created by Pierluigi Cifani on 2/22/16.
//  Copyright © 2016 Wallapop SL. All rights reserved.
//

import BSWFoundation
import Cartography

extension UIView {
    
    func findSubviewWithTag(tag: NSInteger) -> UIView? {
        return subviews.find({return $0.tag == tag})
    }
    
    func removeSubviewWithTag(tag: NSInteger) {
        findSubviewWithTag(tag)?.removeFromSuperview()
    }
    
    func roundCorners() {
        let cornerRadius = CGFloat(10.0)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func getColourFromPoint(point: CGPoint) -> UIColor {
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

    public func distributeHorizontallyViewsInSuperview(views: [UIView]) {
        guard let firstView = views.first else { return }
        guard let lastView = views.last else { return }
        
        constrain(firstView) { firstView in
            firstView.leading == firstView.superview!.leading
        }
        
        constrain(lastView) { lastView in
            lastView.trailing == lastView.superview!.trailing
        }
        
        for i in 1..<views.count {
            let previousView = views[i-1]
            let view = views[i]
            
            constrain(view, previousView) { view, previousView in
                view.leading == previousView.trailing
            }
        }
        
        views.forEach { view in
            constrain(view) { view in
                view.top == view.superview!.top
                view.size == view.superview!.size
            }
        }
    }
}
