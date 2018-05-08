//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class SplitViewController<Master: UIViewController, Detail: UIViewController>: UISplitViewController, UISplitViewControllerDelegate {
    
    open weak var masterVC: Master!
    open weak var detailVC: Detail!
    
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    //MARK:- UISplitViewControllerDelegate
    
    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        //TODO: Review on iPad
        
        return true
    }
    
}
