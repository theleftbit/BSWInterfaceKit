//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit.UIButton)

import UIKit

@available(iOS 17, *)
#Preview {
    let b = CheckboxButton()
    b.configuration?.imagePadding = 8
    b.configuration?.title = "Hello World"
    return b
}

/// Use this button on your app to add a "Checkbox" like UI.
/// To customize it's look and feel, please use `Appearance`
/// to edit the color for the unselected and selected state. You could
/// also provide your own custom images but this is not encouraged
/// since it's better be consistent design with the OS.
@objc(BSWCheckboxButton)
open class CheckboxButton: UIButton {
    
    @MainActor
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
        isSelected = false
        self.configuration = .plain()
        self.configuration?.baseBackgroundColor = .clear
        
        let handler: UIButton.ConfigurationUpdateHandler = { [weak self] button in
            switch button.state {
            case .selected:
                button.configuration?.image = self?.images.selectedImage
                button.configuration?.baseForegroundColor = Appearance.checkTintColor
            default:
                button.configuration?.image = self?.images.nonSelectedImage
                button.configuration?.baseForegroundColor = Appearance.backgroundTintColor
            }
        }
        self.configurationUpdateHandler = handler
        addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
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
