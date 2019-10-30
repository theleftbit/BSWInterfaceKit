//
//  PresentationBackgroundViewController.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//
#if canImport(UIKit)

import UIKit

@objc(BSWPresentationBackgroundView)
class PresentationBackgroundView: UIView {
    weak var parentViewController: UIViewController?
    weak var singleFingerTap: UITapGestureRecognizer?
    
    // Context Properties for CardPresentation
    weak var anchorConstraint: NSLayoutConstraint!
    var position: CardPresentation.AnimationProperties.Position!
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setUp() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
        self.singleFingerTap = singleFingerTap
        self.addGestureRecognizer(singleFingerTap)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func handleSingleTap(_ sender: Any) {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
}
#endif
