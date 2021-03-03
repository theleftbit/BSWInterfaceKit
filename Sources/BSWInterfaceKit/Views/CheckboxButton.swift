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
@available(iOS 13, *)
open class CheckboxButton: UIButton {
    
    public enum Appearance {
        public static var checkTintColor: UIColor = {
            return .systemBlue
        }()
        public static var backgroundTintColor: UIColor = {
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
    }
}
#endif
