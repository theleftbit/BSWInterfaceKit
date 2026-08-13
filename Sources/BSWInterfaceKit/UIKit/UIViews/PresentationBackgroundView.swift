//
//  PresentationBackgroundViewController.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//
#if canImport(UIKit.UIView)

import UIKit

@objc(BSWPresentationBackgroundView)
class PresentationBackgroundView: UIView {
    weak var singleFingerTap: UITapGestureRecognizer?
    
    var context: Context!
    
    struct Context {
        unowned let parentViewController: UIViewController
        let position: CardPresentation.AnimationProperties.Position?
        let offset: CGFloat?
    }

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
        context?.parentViewController.dismiss(animated: true, completion: nil)
    }
}
#endif
