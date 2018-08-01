//
//  Created by Pierluigi Cifani on 01/08/2018.
//

import UIKit

@objc(BSWGradientView)
open class GradientView: UIImageView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        image = GradientFactory.transparentGradient(size: self.frame.size)
    }
}

public enum GradientFactory {
    public static func transparentGradient(size: CGSize) -> UIImage {
        let colorTop = UIColor(white: 0.1, alpha: 0.5)
        let colorBottom = UIColor(white: 0.1, alpha: 0.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.colors = [colorTop, colorBottom].map {$0.cgColor}
        gradientLayer.locations = [0.0, 1.0]
        return UIImage.image(fromGradientLayer: gradientLayer)
    }
}
