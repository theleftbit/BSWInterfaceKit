//
//  Created by Pierluigi Cifani on 29/05/2018.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

/// This View displays `Photo`s in a `UIScrollView` using `UIContentConfiguration` and `UIContentView`
public enum PhotoCollectionViewCell {
    struct Configuration: UIContentConfiguration, Hashable, Sendable {
        
        let photo: Photo
        let imageContentMode: UIView.ContentMode
        let zoomEnabled: Bool
        
        nonisolated(unsafe) var state: UICellConfigurationState?
        
        func makeContentView() -> UIView & UIContentView {
            View(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> PhotoCollectionViewCell.Configuration {
            var mutableCopy = self
            if let cellState = state as? UICellConfigurationState {
                mutableCopy.state =  cellState
            }
            return mutableCopy
        }
    }
    
    @objc(PhotoCollectionView)
    class View: UIView, UIContentView {
        let scrollView = PhotoScrollView()
        
        var configuration: UIContentConfiguration {
            didSet {
                guard let config = configuration as? Configuration,
                      let oldValue = oldValue as? Configuration,
                      oldValue != config else  { return }
                configureFor(configuration: config)
            }
        }
        
        init(configuration: Configuration) {
            self.configuration = configuration
            super.init(frame: .zero)
            
            addSubview(scrollView)
            scrollView.pinToSuperview()
            
            configureFor(configuration: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(configuration: Configuration) {
            scrollView.cellImageView.setPhoto(configuration.photo)
            scrollView.cellImageView.contentMode = configuration.imageContentMode
            scrollView.isUserInteractionEnabled = configuration.zoomEnabled
        }
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

#endif
