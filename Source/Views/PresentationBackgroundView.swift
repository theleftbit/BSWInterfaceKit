//
//  PresentationBackgroundViewController.swift
//  Created by Pierluigi Cifani on 13/08/2018.
//

import UIKit

@objc(BSWPresentationBackgroundView)
class PresentationBackgroundView: UIView {
    weak var parentViewController: UIViewController?
    weak var singleFingerTap: UITapGestureRecognizer?
    
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
