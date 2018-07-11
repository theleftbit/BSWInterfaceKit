//
//  Created by Pierluigi Cifani on 23/04/16.
//  Copyright (c) 2016 TheLeftBit SL. All rights reserved.
//

import UIKit

/*
 This family of protocols have 3 major improvement points:
 
 1.- Clients that want their onboarding to be skippable
 2.- Clients that want their onboarding to hage multiple pages
 3.- Clients that want more social networks available for authentication
 
 Let's revisit this when that happens
 */


//MARK:- Protocols

public protocol OnboardingObserver: class {
    func onFacebookAuthenticationRequested()
}

public protocol OnboardingProvider: class {
    var onboardingCustomization: OnboardingCustomization { get set }
    var onboardingObserver: OnboardingObserver? { get set }
    
    //What should this API look like if more social networks are allowed to login?
}

//MARK:- Type

public struct OnboardingCustomization {

    public enum Background {
        case image(UIImage)
        case color(UIColor)
    }

    public let background: Background
    public let appLogo: UIImage
    public let appSlogan: NSAttributedString
    public let statusBarStyle: UIStatusBarStyle
    
    public init(background: Background, appLogo: UIImage, appSlogan: NSAttributedString, statusBarStyle: UIStatusBarStyle) {
        //This shouldn't be here... No idea why Swift won't create a default init for this
        self.background = background
        self.appLogo = appLogo
        self.appSlogan = appSlogan
        self.statusBarStyle = statusBarStyle
    }
}


open class ClassicOnboardingViewController: LaunchScreenViewController, OnboardingProvider {

    weak open var onboardingObserver: OnboardingObserver? {
        didSet {
            onboardingVC.onboardingObserver = onboardingObserver
        }
    }
    
    open var onboardingCustomization: OnboardingCustomization {
        didSet {
            onboardingVC.onboardingCustomization = onboardingCustomization
        }
    }
    
    let onboardingVC: OnboardingViewController = {
        let controller = OnboardingViewController()
        controller.modalPresentationStyle = .formSheet
        return controller
    }()

    public init(onboardingObserver: OnboardingObserver? = nil, onboardingCustomization: OnboardingCustomization){
        self.onboardingObserver = onboardingObserver
        self.onboardingCustomization = onboardingCustomization
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /**
     Creates the controller to start the onboarding process
     - note: Please set both the observer and the dataSource before calling this method
     - note: This method assumes you use a LaunchScreen.storyboard to launch your app. It'll crash otherwise
     - returns: The viewController you should set as Root of your app's window in order for the onboarding process to proceed
     */
    open override func viewDidLoad() {
        super.viewDidLoad()

        //Hook up the onboardingVC to whatever we have
        onboardingVC.onboardingCustomization = onboardingCustomization
        onboardingVC.onboardingObserver = onboardingObserver
        controllerToPresentOnAppereance = onboardingVC
    }
}

