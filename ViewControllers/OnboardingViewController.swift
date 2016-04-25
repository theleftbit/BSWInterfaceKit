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

    weak var onboardingObserver: OnboardingObserver!
    weak var onboardingDataSource: OnboardingDataSource!
    static let Spacing: CGFloat = 10
    
    let socialStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.distribution = .FillProportionally
        stackView.spacing = OnboardingViewController.Spacing
        return stackView
    }()

    let logoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.distribution = .FillProportionally
        stackView.spacing = OnboardingViewController.Spacing
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //First, the background
        switch onboardingDataSource.onboardingBackground() {
        case .Color(let color):
            view.backgroundColor = color
        case .Image(let image):
            let imageView = UIImageView(image: image)
            view.addSubview(imageView)
            constrain(imageView) { imageView in
                imageView.edges == imageView.superview!.edges
            }
        }
        
        //Then, the stackViews
        view.addSubview(logoStackView)
        view.addSubview(socialStackView)
        constrain(logoStackView, socialStackView) { logoStackView, socialStackView in
            logoStackView.top == logoStackView.superview!.top + OnboardingViewController.Spacing
            logoStackView.leading == logoStackView.superview!.leading + OnboardingViewController.Spacing
            logoStackView.trailing == logoStackView.superview!.trailing - OnboardingViewController.Spacing

            socialStackView.bottom == socialStackView.superview!.bottom - OnboardingViewController.Spacing
            socialStackView.leading == socialStackView.superview!.leading + OnboardingViewController.Spacing
            socialStackView.trailing == socialStackView.superview!.trailing - OnboardingViewController.Spacing
        }
        
        prepareLogoStackView()
        prepareSocialStackView()
    }
    
    @objc func onLoginFacebook() {
        onboardingObserver.onFacebookAuthenticationRequested()
    }
    
    //MARK:- Private

    private func prepareSocialStackView() {
        
        let privacyLabel: UILabel = {
            let label = UILabel()
            label.text = "We will never post in your wall"
            label.textAlignment = .Center
            label.numberOfLines = 0
            return label
        }()
        
        socialStackView.addArrangedSubview(privacyLabel)
        
        let facebookButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.blueColor()
            button.setTitle("Login with Facebook", forState: .Normal)
            button.addTarget(self, action: #selector(onLoginFacebook), forControlEvents: UIControlEvents.TouchDown)
            return button
        }()
        
        socialStackView.addArrangedSubview(facebookButton)
    }
    
    private func prepareLogoStackView() {
        
        let logoView: UIImageView = {
            let imageView = UIImageView(image: onboardingDataSource.onboardingAppLogo())
            imageView.contentMode = .ScaleAspectFit
            return imageView
        }()
        
        logoStackView.addArrangedSubview(logoView)
        
        let sloganLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.attributedText = onboardingDataSource.onboardingAppSlogan()
            return label
        }()
        
        logoStackView.addArrangedSubview(sloganLabel)
    }
}
