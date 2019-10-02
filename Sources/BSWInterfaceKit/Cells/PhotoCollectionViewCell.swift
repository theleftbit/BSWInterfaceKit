//
//  Created by Pierluigi Cifani on 29/05/2018.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public class PhotoCollectionViewCell: UICollectionViewCell, ViewModelReusable {

    let scrollView = PhotoScrollView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.pinToSuperview()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func configureFor(viewModel: Photo) {
        scrollView.cellImageView.setPhoto(viewModel)
    }
    
}

class PhotoScrollView: UIScrollView, UIScrollViewDelegate {
    
    let cellImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: .zero)
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 3.5

        addSubview(cellImageView)
        cellImageView.pinToSuperview()
        cellImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        cellImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapZoom))
        tapRecognizer.numberOfTapsRequired = 2
        cellImageView.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isZoomed: Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    //MARK: UIResponder
    
    // This overrides make sure that the touches are
    // forwarded to the superview (in this case, a collectionView)
    // so the default behaviour happens in case the user isn't zooming
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesCancelled(touches, with: event)
        } else {
            superview?.touchesCancelled(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesMoved(touches, with: event)
        } else {
            superview?.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesBegan(touches, with: event)
        } else {
            superview?.touchesBegan(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesEnded(touches, with: event)
        } else {
            superview?.touchesEnded(touches, with: event)
        }
    }
    
    //MARK: IBAction
    
    @objc func tapZoom() {
        if isZoomed {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }
    
    //MARK: UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        cellImageView
    }
}
