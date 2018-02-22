//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import BSWInterfaceKit
import Deferred

private let FacebookAppID = "194840897775038"

class FacebookLoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let buttonConfig = ButtonConfiguration(title: "Login With Facebook", titleColor: UIColor.blue) { [weak self] in
            guard let `self` = self else { return }
            self.loginWithFacebook()
        }

        let loginButton = UIButton(buttonConfiguration: buttonConfig)
        view.addSubview(loginButton)
        loginButton.centerInSuperview()
    }

    private func loginWithFacebook() {
        guard #available(iOS 11, *) else { return }
        let socialManager = SocialAuthenticationManager.manager
        let task = socialManager.loginWithFacebook(credentials: SocialAuthenticationManager.FacebookCredentials(appID: FacebookAppID))
        task.upon(.main, execute: { [weak self] (result) in
            guard let `self` = self else { return }
            let title: String
            let message: String
            switch result {
            case .failure(let error):
                title = "Error"
                message = error.localizedDescription
            case .success(let token):
                title = "Success"
                message = "Login token is: \(token)"
            }

            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            controller.addAction(action)

            self.present(controller, animated: true, completion: nil)
        })
    }
}
