//
//  Created by Pierluigi Cifani on 09/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

public protocol PhotoGalleryViewControllerDelegate: class {
    func photoGalleryController(_ photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: Int)
}

public final class PhotoGalleryViewController: UIViewController {
    
    public enum Appearance {
        static public var BackgroundColor: UIColor = .black
        static public var TintColor: UIColor = .white
    }

    private let photosGallery: PhotoGalleryView
    public var allowShare: Bool
    public weak var delegate: PhotoGalleryViewControllerDelegate?
    public var currentPage: Int = 0
    public var photos: [Photo] {
        return photosGallery.photos
    }

    public init(photos: [Photo],
         initialPageIndex: Int = 0,
         allowShare: Bool = true) {
        self.allowShare = allowShare
        self.photosGallery = PhotoGalleryView(photos: photos, imageContentMode: .scaleAspectFit)
        self.currentPage = initialPageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override public func loadView() {
        view = UIView()
        view.backgroundColor = Appearance.BackgroundColor
        photosGallery.backgroundColor = Appearance.BackgroundColor
        photosGallery.zoomEnabled = true

        //Set up the Gallery
        view.addSubview(photosGallery)
        photosGallery.pinToSuperview()
        
        //Add the close button
        let closeButton: UIButton = {
            if #available(iOS 13.0, *) {
                let closeButton = UIButton.systemButton(with: UIImage.templateImage(.close), target: self, action: #selector(onCloseButton))
                closeButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: .largeTitle, scale: .small), forImageIn: .normal)
                return closeButton
            } else {
                let closeButton = UIButton(type: .custom)
                closeButton.addTarget(self, action: #selector(onCloseButton), for: .touchDown)
                let image = UIImage.templateImage(.close).withRenderingMode(.alwaysTemplate)
                closeButton.setImage(image, for: .normal)
                return closeButton
            }
        }()

        closeButton.tintColor = Appearance.TintColor
        view.addAutolayoutSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 12)
        ])
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
        }, completion: { _ in
            self.photosGallery.invalidateLayout()
        })
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photosGallery.invalidateLayout()
        photosGallery.scrollToPhoto(atIndex: currentPage)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentationController?.delegate = self
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    //MARK:- IBActions
    
    @objc func onCloseButton() {
        delegate?.photoGalleryController(self, willDismissAtPageIndex: photosGallery.currentPage)
        self.dismiss(animated: true, completion: nil)
    }
}

extension PhotoGalleryViewController: UIAdaptivePresentationControllerDelegate {
    
    @available(iOS 13.0, *)
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        delegate?.photoGalleryController(self, willDismissAtPageIndex: photosGallery.currentPage)
    }
}
#endif
