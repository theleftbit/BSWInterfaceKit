//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

class AvatarView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    private let size: Size
    
    var placeholderImage: UIImage?
    var imageURL: NSURL? {
        didSet {
            updateImage()
        }
    }
    
    // MARK: Initialization
    
    init(size: Size, imageURL: NSURL? = nil, placeholderImage: UIImage? = nil) {
        self.size = size
        self.placeholderImage = placeholderImage
        self.imageURL = imageURL
        super.init(frame: CGRectZero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View setup
    
    private func setup() {
        layer.masksToBounds = true
        addSubview(imageView)
        updateImage()
        setupConstraints()
    }
    
    private func updateImage() {
        imageView.image = placeholderImage
        if let imageURL = imageURL {
            imageView.bsw_setImageFromURL(imageURL)
        }
    }
    
    // MARK: Constraints
    
    private func setupConstraints() {
        self.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        self.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        constrain(imageView) { imageView in
            imageView.edges == imageView.superview!.edges
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: size.rawValue, height: size.rawValue)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = CGRectGetWidth(bounds) / 2
    }
    
    // MARK: Avatar size
    
    enum Size: CGFloat {
        case Smallest = 18
        case Small = 25
        case Medium = 30
        case Big = 40
        case Bigger = 44
        case Biggest = 60
        case Huge = 80
    }
    
}
