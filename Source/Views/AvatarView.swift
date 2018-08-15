//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWAvatarView)
public class AvatarView: UIView {
    
    public let size: Size
    
    public var photo: Photo {
        didSet {
            updateImage()
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var onTapOnAvatar: AvatarTouchHandler? {
        didSet {
            if let tapRecognizer = self.tapRecognizer {
                self.removeGestureRecognizer(tapRecognizer)
                self.tapRecognizer = nil
            }
            cameraImageView.removeFromSuperview()

            if let _ = onTapOnAvatar {
                self.isUserInteractionEnabled = true
                tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
                self.addGestureRecognizer(tapRecognizer!)
                
                cameraImageView.translatesAutoresizingMaskIntoConstraints = false
                addAutolayoutSubview(cameraImageView)
                cameraImageView.centerInSuperview()
                NSLayoutConstraint.activate([
                    cameraImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
                    cameraImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25),
                    ])
            } else {
                self.isUserInteractionEnabled = true
            }
        }
    }

    private var tapRecognizer: UITapGestureRecognizer?
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        let cameraImage = UIImage.templateImage(.camera)
        imageView.image = cameraImage.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        return imageView
    }()

    // MARK: Initialization
    
    public init(size: Size, photo: Photo) {
        self.size = size
        self.photo = photo
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View setup
    
    fileprivate func setup() {
        layer.masksToBounds = true
        addAutolayoutSubview(imageView)
        imageView.pinToSuperview()
        updateImage()
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    fileprivate func updateImage() {
        imageView.setPhoto(photo)
    }
    
  // MARK: Layout

    override public var intrinsicContentSize : CGSize {
        return CGSize(width: size.rawValue, height: size.rawValue)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: TapReco
    
    @objc func onTap() {
        onTapOnAvatar?(self)
    }
    
    // MARK: Types
    
    public enum Size: CGFloat {
        case smallest = 44
        case normal = 60
        case big = 80
        case huge = 140
    }
    
    public typealias AvatarTouchHandler = (AvatarView) -> ()
}
