//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public class SplitViewController<Master: UIViewController, Detail: UIViewController>: UISplitViewController, UISplitViewControllerDelegate {
    
    public weak var masterVC: Master!
    public weak var detailVC: Detail!
    
    public init(masterVC: Master, detailVC: Detail) {
        
        self.masterVC = masterVC
        self.detailVC = detailVC
        
        super.init(nibName: nil, bundle: nil)
        viewControllers = [
            UINavigationController(rootViewController: masterVC),
            UINavigationController(rootViewController: detailVC),
        ]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    //MARK:- UISplitViewControllerDelegate
    
    public func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        
        //TODO: Review on iPad
        
        return true
    }
    
}
