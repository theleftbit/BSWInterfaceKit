//
//  Created by Pierluigi Cifani.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWCheckboxButton)
public class CheckboxButton: UIButton {

    private enum Constants {
        static let ImageInset = CGFloat(10)
    }

    public init() {
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFit
        self.setImage(UIImage.interfaceKitImageNamed("ic_checkbox"), for: .normal)
        self.setImage(UIImage.interfaceKitImageNamed("ic_checkbox_selected"), for: .selected)
        self.imageEdgeInsets = [.left: -Constants.ImageInset]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        let superIntrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: superIntrinsicContentSize.width + Constants.ImageInset, height: superIntrinsicContentSize.height)
    }

}
