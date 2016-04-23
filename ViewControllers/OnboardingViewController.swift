//
//  Created by Pierluigi Cifani on 23/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

class LaunchScreenViewController: UIViewController {
    
    var controllerToPresentOnAppereance: UIViewController?
    
    override func loadView() {
        //Folks, don't do this at home!
        let baseVC = UIStoryboard(name: "LaunchScreen", bundle: NSBundle.mainBundle()).instantiateInitialViewController()!
        let view = baseVC.view
        baseVC.view = nil
        self.view = view
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let controllerToPresentOnAppereance = controllerToPresentOnAppereance {
            presentViewController(controllerToPresentOnAppereance, animated: true, completion: nil)
        }
    }
}

class OnboardingViewController: UIViewController {

    weak var onboardingObserver: OnboardingObserver?
    weak var onboardingDataSource: OnboardingDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
    }
    
}
