//
//  Created by Pierluigi Cifani on 23/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

open class LaunchScreenViewController: UIViewController {
    
    open var controllerToPresentOnAppereance: UIViewController?
    open var showSpinner = false
    
    open override func loadView() {
        //Folks, don't do this at home!
        let baseVC = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()!
        let view = baseVC.view
        baseVC.view = nil
        self.view = view
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if showSpinner {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            view.addSubview(spinner)
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
                ])
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let controllerToPresentOnAppereance = controllerToPresentOnAppereance else { return }
        present(controllerToPresentOnAppereance, animated: true, completion: nil)
        self.controllerToPresentOnAppereance = nil
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
}

class OnboardingViewController: UIViewController {

    weak var onboardingObserver: OnboardingObserver!
    var onboardingCustomization: OnboardingCustomization!
    private static let Spacing: CGFloat = 10
    private let contentView = UIView()
    
    let socialStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = OnboardingViewController.Spacing
        return stackView
    }()

    let logoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = OnboardingViewController.Spacing
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addAutolayoutSubview(contentView)
        contentView.pinToSuperview()
        
        //First, the background
        switch onboardingCustomization.background {
        case .color(let color):
            view.backgroundColor = color
        case .image(let image):
            let imageView = UIImageView(image: image)
            contentView.addSubview(imageView)
            imageView.pinToSuperview()
        }
        
        //Then, the stackViews
        contentView.addAutolayoutSubview(logoStackView)
        contentView.addAutolayoutSubview(socialStackView)

        NSLayoutConstraint.activate([
            logoStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            logoStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            logoStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            socialStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            socialStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            socialStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            socialStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
            ])

        prepareLogoStackView()
        prepareSocialStackView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        prepareMarginsForCurrentTraitCollection()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return onboardingCustomization.statusBarStyle
    }
    
    //MARK:- IBAction
    
    @objc func onLoginFacebook() {
        onboardingObserver.onFacebookAuthenticationRequested()
    }

    //MARK:- Private

    fileprivate func prepareMarginsForCurrentTraitCollection() {
        switch self.traitCollection.verticalSizeClass {
        case .regular:
            contentView.layoutMargins = [.top: 40, .left: 8, .bottom: 8, .right: 8]
        case .compact:
            contentView.layoutMargins = UIEdgeInsets(uniform: 8)
        case .unspecified:
            contentView.layoutMargins = UIEdgeInsets(uniform: 8)
        }
    }
    
    fileprivate func prepareSocialStackView() {
        
        let privacyLabel: UILabel = {
            let label = UILabel()
            label.text = "We will never post in your wall"
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        socialStackView.addArrangedSubview(privacyLabel)
        
        let facebookButton: UIButton = {
            let config = ButtonConfiguration(
                title: "Login with Facebook",
                titleColor: .white,
                backgroundColor: .blue,
                actionHandler: { [weak self] in
                    self?.onLoginFacebook()
            })
            return UIButton(buttonConfiguration: config)
        }()
        
        socialStackView.addArrangedSubview(facebookButton)
    }
    
    fileprivate func prepareLogoStackView() {
        
        let logoView: UIImageView = {
            let imageView = UIImageView(image: onboardingCustomization.appLogo)
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        logoStackView.addArrangedSubview(logoView)
        
        let sloganLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.attributedText = onboardingCustomization.appSlogan
            return label
        }()
        
        logoStackView.addArrangedSubview(sloganLabel)
    }
}
