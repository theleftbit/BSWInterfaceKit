//
//  SwiftyGestureRecognition.swift
//  SwiftyGestureRecognition
//
//  Created by Adam Bell on 1/26/16.
//  Copyright © 2016 Adam Bell. All rights reserved.
//

import ObjectiveC
import UIKit

public typealias UIGestureRecognizerStateChangeBlock = ((gestureRecognizer: UIGestureRecognizer) -> Void)

private class UIGestureRecognizerStateChangeBlockHost {
    
    weak var gestureRecognizer: UIGestureRecognizer?
    
    var block: [UIGestureRecognizerState: UIGestureRecognizerStateChangeBlock] = [:]
    
    init(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.addTarget(self, action: #selector(UIGestureRecognizerStateChangeBlockHost.gestureRecognizerStateChanged(_:)))
    }
    
    deinit {
        gestureRecognizer?.removeTarget(self, action: #selector(UIGestureRecognizerStateChangeBlockHost.gestureRecognizerStateChanged(_:)))
    }
    
    @objc private func gestureRecognizerStateChanged(gestureRecognizer: UIGestureRecognizer) {
        if let stateChangeBlock = block[gestureRecognizer.state] {
            stateChangeBlock(gestureRecognizer: gestureRecognizer)
        }
    }
    
}

public extension UIGestureRecognizer {
    
    private struct AssociatedBlockHost {
        static var blockHost = "blockHost"
    }
    
    private var blockHost: UIGestureRecognizerStateChangeBlockHost {
        get {
            if let blockHost = objc_getAssociatedObject(self, &AssociatedBlockHost.blockHost) as? UIGestureRecognizerStateChangeBlockHost {
                return blockHost
            } else {
                let blockHost = UIGestureRecognizerStateChangeBlockHost(gestureRecognizer: self)
                objc_setAssociatedObject(self, &AssociatedBlockHost.blockHost, blockHost, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return blockHost
            }
        }
    }
    
    convenience init(view: UIView?) {
        self.init()
        view?.addGestureRecognizer(self)
    }
    
    public func didBegin(didBegin: UIGestureRecognizerStateChangeBlock?) -> UIGestureRecognizer {
        blockHost.block[.Began] = didBegin
        return self
    }
    
    public func didChange(didChange: UIGestureRecognizerStateChangeBlock?) -> UIGestureRecognizer {
        blockHost.block[.Changed] = didChange
        return self
    }
    
    public func didEnd(didEnd: UIGestureRecognizerStateChangeBlock?) -> UIGestureRecognizer {
        blockHost.block[.Ended] = didEnd
        return self
    }
    
    public func didCancel(didCancel: UIGestureRecognizerStateChangeBlock?) -> UIGestureRecognizer {
        blockHost.block[.Cancelled] = didCancel
        return self
    }
    
    public func didFail(didFail: UIGestureRecognizerStateChangeBlock?) -> UIGestureRecognizer {
        blockHost.block[.Failed] = didFail
        return self
    }
    
}