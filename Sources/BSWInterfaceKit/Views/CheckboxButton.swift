//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

/// Use this button on your app to add a "Checkbox" like UI.
/// To customize it's look and feel, please use `Appearance`
/// to edit the color for the unselected and selected state. You could
/// also provide your own custom images but this is not encouraged
/// since it's better be consistent design with the OS.
@objc(BSWCheckboxButton)
open class CheckboxButton: UIButton {
    
    public enum Appearance {
        public static var checkTintColor: UIColor = {
            return .systemBlue
        }()
        public static var backgroundTintColor: UIColor = {
            return .opaqueSeparator
        }()
        public static var images: (nonSelectedImage: UIImage, selectedImage: UIImage)? = nil
    }
    
    private var images: (nonSelectedImage: UIImage, selectedImage: UIImage) {
        if let updatedImages = Appearance.images {
            return updatedImages
        } else {
            return CheckboxButton.generateImages()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        self.configuration = .plain()
        isSelected = false
        addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override var isSelected: Bool {
        didSet {
            self.configuration?.image = isSelected ? images.selectedImage : images.nonSelectedImage
            self.configuration?.baseForegroundColor = isSelected ? Appearance.checkTintColor : Appearance.backgroundTintColor
            self.configuration?.baseBackgroundColor = .clear
        }
    }
    
    @objc private func toggleSelected() {
        isSelected.toggle()
    }
    
    static fileprivate func generateImages() -> (nonSelectedImage: UIImage, selectedImage: UIImage) {
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
