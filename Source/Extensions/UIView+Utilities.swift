//
//  Created by Pierluigi Cifani on 2/22/16.
//  Copyright © 2016 Blurred Software SL SL. All rights reserved.
//

import BSWFoundation
import Cartography

extension UIView {
    
    public func findSubviewWithTag(_ tag: NSInteger) -> UIView? {
        return subviews.find(predicate: { return $0.tag == tag} )
    }
    
    public func removeSubviewWithTag(_ tag: NSInteger) {
        findSubviewWithTag(tag)?.removeFromSuperview()
    }
    
    public func roundCorners() {
        let cornerRadius = CGFloat(10.0)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    public func getColorFromPoint(_ point: CGPoint) -> UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.translateBy(x: -point.x, y: -point.y);
        self.layer.render(in: context!)
        
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    public func fillSuperview(withEdges edges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        constrain(self) { view in
            view.edges == inset(view.superview!.edges, edges.top, edges.left, edges.bottom, edges.right)
        }
    }

    public func centerInSuperview() {
        constrain(self) { view in
            view.center == view.superview!.center
        }
    }

    public class func instantiateFromNib<T: UIView>(_ viewType: T.Type) -> T? {
        let className = NSStringFromClass(viewType).components(separatedBy: ".").last!
        let bundle = Bundle(for: self)
        return bundle.loadNibNamed(className, owner: nil, options: nil)?.first as? T
    }
    
    public class func instantiateFromNib() -> Self? {
        return instantiateFromNib(self)
    }
}
