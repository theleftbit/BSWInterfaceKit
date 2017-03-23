//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class CheckboxButton: UIButton {

    private enum Constants {
        static let ImageInset = CGFloat(10)
    }

    public init() {
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFit
        self.setImage(UIImage.interfaceKitImageNamed("ic_checkbox"), for: .normal)
        self.setImage(UIImage.interfaceKitImageNamed("ic_checkbox_selected"), for: .selected)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -Constants.ImageInset, bottom: 0, right: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        let superIntrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: superIntrinsicContentSize.width + Constants.ImageInset, height: superIntrinsicContentSize.height)
    }

}
