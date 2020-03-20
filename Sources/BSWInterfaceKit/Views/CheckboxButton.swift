//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

/// Use this button on your app to add a "Checkbox" like UI.
/// To customize it's look and feel, please use `Appereance`
/// to edit the color for the unselected and selected state. You could
/// also provide your own custom images but this is not encouraged
/// since it's better be consistent design with the OS.
@objc(BSWCheckboxButton)
open class CheckboxButton: UIButton {
    
    public enum Appearance {
        public static var checkTintColor: UIColor = {
            guard #available(iOS 13.0, tvOS 13.0, *) else {
                return .black
            }
            return .systemBlue
        }()
        public static var backgroundTintColor: UIColor = {
            guard #available(iOS 13.0, tvOS 13.0, *) else {
                return UIColor(r: 243, g: 243, b: 243)
            }
            return .opaqueSeparator
        }()
        public static var images: (nonSelectedImage: UIImage, selectedImage: UIImage)? = nil
        public static var Padding = CGFloat(10)
    }
    
    public init() {
        super.init(frame: .zero)
        
        let images: (nonSelectedImage: UIImage, selectedImage: UIImage) = {
            if let updatedImages = Appearance.images {
                return updatedImages
            } else {
                return CheckboxButton.generateImages()
            }
        }()
        self.setImage(images.nonSelectedImage, for: .normal)
        self.setImage(images.selectedImage, for: .selected)
        self.titleEdgeInsets = [.right: -Appearance.Padding, .left: Appearance.Padding]
        self.contentEdgeInsets = [.right: Appearance.Padding]
        addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
        isSelected = false
    }
    
    @objc private func toggleSelected() {
        isSelected.toggle()
    }
    
    public override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? Appearance.checkTintColor : Appearance.backgroundTintColor
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static private func generateImages() -> (nonSelectedImage: UIImage, selectedImage: UIImage) {
        /// These are good to go  since they're generated using
        /// `UIImage(systemName:)`. For iOS 12, since they're
        /// generated manually from a PDF, we need to draw them
        if #available(iOS 13.0, tvOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(scale: .large)
            let backgroundImage: UIImage = {
                return UIImage.init(systemName: "circle", withConfiguration: config)!
                    .withTintColor(Appearance.backgroundTintColor, renderingMode: .alwaysTemplate)
            }()
            let checkboxImage: UIImage = {
                return UIImage.init(systemName: "checkmark.circle.fill", withConfiguration: config)!
                    .withTintColor(Appearance.checkTintColor, renderingMode: .alwaysTemplate)
            }()
            return (backgroundImage, checkboxImage)
        } else {
            
            let backgroundImage: UIImage = {
                let image = UIImage.templateImage(.rectangle)
                return image.tint(Appearance.backgroundTintColor)
            }()
            let checkboxImage: UIImage = {
                let image = UIImage.templateImage(.checkmark)
                return image.tint(Appearance.checkTintColor)
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
}
#endif
