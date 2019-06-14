//
//  Created by Pierluigi Cifani on 01/08/2018.
//

import UIKit

@objc(BSWGradientView)
open class GradientView: UIImageView {
    
    public enum Kind {
        case transparent
        case colors([UIColor])
    }
    
    public let kind: Kind
    
    public init(kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        switch kind {
        case .colors(let colors):
            image = GradientFactory.gradientFromColors(colors: colors, size: self.frame.size)
        case .transparent:
            image = GradientFactory.transparentGradient(size: self.frame.size)
        }
    }
}

public enum GradientFactory {
    
    public static func transparentGradient(size: CGSize, isHorizontal: Bool = true) -> UIImage {
        let colorTop = UIColor(white: 0.1, alpha: 0.5)
        let colorBottom = UIColor(white: 0.1, alpha: 0.0)
        return gradientFromColors(colors: [colorTop, colorBottom], size: size, isHorizontal: isHorizontal)
    }

    public static func gradientFromColors(colors: [UIColor], size: CGSize, isHorizontal: Bool = true) -> UIImage {
        let gradientLayer = gradientLayerFromColors(colors: colors, size: size, isHorizontal: isHorizontal)
        return UIImage.image(fromGradientLayer: gradientLayer)
    }
    
    public static func gradientLayerFromColors(colors: [UIColor], size: CGSize, isHorizontal: Bool = true) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.colors = colors.map {$0.cgColor}
        gradientLayer.locations = [0.0, 1.0]
        if isHorizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        return gradientLayer
    }
}
