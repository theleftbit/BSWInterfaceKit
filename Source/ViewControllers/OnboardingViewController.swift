//
//  Created by Pierluigi Cifani on 23/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

public class LaunchScreenViewController: UIViewController {
    
    public var controllerToPresentOnAppereance: UIViewController?
    public var showSpinner = false
    
    public override func loadView() {
        //Folks, don't do this at home!
        let baseVC = UIStoryboard(name: "LaunchScreen", bundle: NSBundle.mainBundle()).instantiateInitialViewController()!
        let view = baseVC.view
        baseVC.view = nil
        self.view = view
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if showSpinner {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            view.addSubview(spinner)
            spinner.startAnimating()
            constrain(spinner) { spinner in
                spinner.bottom == spinner.superview!.bottom - 80
                spinner.centerX == spinner.superview!.centerX
            }
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let controllerToPresentOnAppereance = controllerToPresentOnAppereance else { return }
        presentViewController(controllerToPresentOnAppereance, animated: true, completion: nil)
        self.controllerToPresentOnAppereance = nil
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

class OnboardingViewController: UIViewController {

    weak var onboardingObserver: OnboardingObserver!
    var onboardingCustomization: OnboardingCustomization!
    static let Spacing: CGFloat = 10
    let contentView = UIView()
    
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
        view.addSubview(contentView)
        constrain(contentView) { contentView in
            contentView.edges == contentView.superview!.edges
        }
        
        //First, the background
        switch onboardingCustomization.background {
        case .Color(let color):
            view.backgroundColor = color
        case .Image(let image):
            let imageView = UIImageView(image: image)
            contentView.addSubview(imageView)
            constrain(imageView) { imageView in
                imageView.edges == imageView.superview!.edges
            }
        }
        
        //Then, the stackViews
        contentView.addSubview(logoStackView)
        contentView.addSubview(socialStackView)
        constrain(logoStackView, socialStackView) { logoStackView, socialStackView in
            logoStackView.topMargin == logoStackView.superview!.topMargin
            logoStackView.leadingMargin == logoStackView.superview!.leadingMargin
            logoStackView.trailingMargin == logoStackView.superview!.trailingMargin
            socialStackView.bottomMargin == socialStackView.superview!.bottomMargin
            socialStackView.leadingMargin == socialStackView.superview!.leadingMargin
            socialStackView.trailingMargin == socialStackView.superview!.trailingMargin
        }
        
        prepareLogoStackView()
        prepareSocialStackView()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        prepareMarginsForCurrentTraitCollection()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return onboardingCustomization.statusBarStyle
    }
    
    //MARK:- IBAction
    
    @objc func onLoginFacebook() {
        onboardingObserver.onFacebookAuthenticationRequested()
    }

    //MARK:- Private

    private func prepareMarginsForCurrentTraitCollection() {
        switch self.traitCollection.verticalSizeClass {
        case .Regular:
            contentView.layoutMargins = UIEdgeInsetsMake(40, 8, 8, 8)
        case .Compact:
            contentView.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)
        case .Unspecified:
            contentView.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)
        }
    }
    
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
            let button = LoginButton(
                title: "Login with Facebook",
                target: self,
                selector: #selector(onLoginFacebook),
                color: UIColor.blueColor()
            )
            return button
        }()
        
        socialStackView.addArrangedSubview(facebookButton)
    }
    
    private func prepareLogoStackView() {
        
        let logoView: UIImageView = {
            let imageView = UIImageView(image: onboardingCustomization.appLogo)
            imageView.contentMode = .ScaleAspectFit
            return imageView
        }()
        
        logoStackView.addArrangedSubview(logoView)
        
        let sloganLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .Center
            label.attributedText = onboardingCustomization.appSlogan
            return label
        }()
        
        logoStackView.addArrangedSubview(sloganLabel)
    }
}
