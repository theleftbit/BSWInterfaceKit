//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWCheckboxButton)
public class CheckboxButton: UIButton {

    public enum Appearance {
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
        let backgroundImage: UIImage = {
            let image = UIImage.interfaceKitImageNamed("rectangle.fill")!
            if #available(iOS 13.0, *) {
                return image.withTintColor(Appearance.backgroundTintColor)
            } else {
                return image.tint(Appearance.backgroundTintColor)
            }
        }()

        let checkboxImage: UIImage = {
            let image = UIImage.interfaceKitImageNamed("checkmark")!
            if #available(iOS 13.0, *) {
                return image.withTintColor(Appearance.checkTintColor)
            } else {
                return image.tint(Appearance.checkTintColor)
            }
        }()

        let targetSize = CGSize(width: 36, height: 36)
        let horizontalPadding: CGFloat = 6
        let verticalPadding: CGFloat = 9

        let areaSize = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        let areaSize2 = CGRect(x: horizontalPadding, y: verticalPadding, width: targetSize.width - 2*horizontalPadding, height: targetSize.height - 2*verticalPadding)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let newCheckboxImage = renderer.image { ctx in
            backgroundImage.draw(in: areaSize)
            checkboxImage.draw(in: areaSize2, blendMode: .normal, alpha: 1)
        }

        let newBackgroundImage = renderer.image { ctx in
            backgroundImage.draw(in: areaSize)
        }

        return (newBackgroundImage, newCheckboxImage)
    }
}
