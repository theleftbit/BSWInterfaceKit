//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

#if compiler(>=5.9)
#Preview {
    return AvatarView(size: .big, photo: .emptyPhoto())
}
#endif

/// This subclass of `UIView` displays it's `Photo` as a round image, perfect for showing avatars.
@objc(BSWAvatarView)
public class AvatarView: UIView {
    
    public let size: Size
    
    /// The `Photo` of the avatar displayed
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
    
    /// A handler called whenever the user touches on this view.
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
        imageView.image = UIImage.init(systemName: "camera")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: Initialization
    
    
    /// Initializes this view with a `Size` and a `Photo`
    /// - Parameters:
    ///   - size: The `Size`
    ///   - photo: The `Photo`
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
    
    private func setup() {
        layer.masksToBounds = true
        addAutolayoutSubview(imageView)
        imageView.pinToSuperview()
        updateImage()
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func updateImage() {
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
    
    @objc private func onTap() {
        onTapOnAvatar?(self)
    }
    
    // MARK: Types
    
    /// This type represents the size that the `AvatarView` will be shown at.
    public enum Size: CGFloat {
        case smallest = 44
        case normal = 60
        case big = 80
        case huge = 140
    }
    
    public typealias AvatarTouchHandler = (AvatarView) -> ()
}
#endif
