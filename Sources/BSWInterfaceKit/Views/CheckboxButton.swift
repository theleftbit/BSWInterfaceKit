//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWCheckboxButton)
public class CheckboxButton: UIButton {

    public enum Appereance {
        public static var checkTintColor: UIColor = .black
        public static var backgroundTintColor = UIColor(r: 243, g: 243, b: 243)
    }
    
    private enum Constants {
        static let ImageInset = CGFloat(10)
    }

    public init() {
        super.init(frame: .zero)
        

        let images = CheckboxButton.generateImages()
        self.contentMode = .scaleAspectFit
        self.setImage(images.nonSelectedImage, for: .normal)
        self.setImage(images.selectedImage, for: .selected)
        self.imageEdgeInsets = [.left: -Constants.ImageInset]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        let superIntrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: superIntrinsicContentSize.width + Constants.ImageInset, height: superIntrinsicContentSize.height)
    }
    
    static private func generateImages() -> (nonSelectedImage: UIImage, selectedImage: UIImage) {
        let nonSelectedImage = UIImage.interfaceKitImageNamed("ic_checkbox_background")!.tint(Appereance.backgroundTintColor)
        
        let checkboxImage = UIImage.interfaceKitImageNamed("ic_checkbox_check")!.tint(Appereance.checkTintColor)
        let size = nonSelectedImage.size
        let padding: CGFloat = 5
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let areaSize2 = CGRect(x: padding, y: padding, width: size.width - 2*padding, height: size.height - 2*padding)
        nonSelectedImage.draw(in: areaSize)
        checkboxImage.draw(in: areaSize2, blendMode: .normal, alpha: 1)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return (nonSelectedImage, newImage)
    }
}
