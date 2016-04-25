//
//  Created by Pierluigi Cifani on 23/04/16.
//  Copyright (c) 2016 Blurred Software SL. All rights reserved.
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

public protocol OnboardingDataSource: class {
    func onboardingBackground() -> OnboardingBackground
    func onboardingAppLogo() -> UIImage
    func onboardingAppSlogan() -> NSAttributedString
}

public protocol OnboardingProvider: class {
    func rootViewController() -> UIViewController
    weak var onboardingObserver: OnboardingObserver? { get set }
    weak var onboardingDataSource: OnboardingDataSource? { get set }
    
    //What should this API look like if more social networks are allowed to login?
}

//MARK:- Type

public enum OnboardingBackground {
    case Image(UIImage)
    case Color(UIColor)
}

public class ClassicOnboardingProvider: OnboardingProvider {

    weak public var onboardingObserver: OnboardingObserver? {
        didSet {
            onboardingVC.onboardingObserver = onboardingObserver
        }
    }
    
    weak public var onboardingDataSource: OnboardingDataSource? {
        didSet {
            onboardingVC.onboardingDataSource = onboardingDataSource
        }
    }
    
    let onboardingVC: OnboardingViewController = {
        let controller = OnboardingViewController()
        controller.modalPresentationStyle = .FormSheet
        return controller
    }()

    public init(onboardingObserver: OnboardingObserver? = nil, onboardingDataSource: OnboardingDataSource? = nil){
        self.onboardingObserver = onboardingObserver
        self.onboardingDataSource = onboardingDataSource
    }
    
    /**
     Creates the controller to start the onboarding process
     - note: Please set both the observer and the dataSource before calling this method
     - note: This method assumes you use a LaunchScreen.storyboard to launch your app. It'll crash otherwise
     - returns: The viewController you should set as Root of your app's window in order for the onboarding process to proceed
     */
    public func rootViewController() -> UIViewController {
        
        //Hook up the onboardingVC to whatever we have
        onboardingVC.onboardingDataSource = onboardingDataSource
        onboardingVC.onboardingObserver = onboardingObserver

        let rootVC = LaunchScreenViewController()
        rootVC.controllerToPresentOnAppereance = onboardingVC
        return rootVC
    }
    
}

