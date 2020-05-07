//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import BSWInterfaceKit
import Deferred

private let FacebookAppID = "726622887875928"

class FacebookLoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let buttonConfig = ButtonConfiguration(title: "Login With Facebook", titleColor: self.view.tintColor) { [weak self] in
            guard let `self` = self else { return }
            self.loginWithFacebook()
        }

        let loginButton = UIButton(buttonConfiguration: buttonConfig)
        view.addSubview(loginButton)
        loginButton.centerInSuperview()
    }

    private func loginWithFacebook() {
        let credentials = SocialAuthenticationManager.FacebookCredentials(
            appID: FacebookAppID,
            scope: [.email, .publicProfile]
        )
        let task = SocialAuthenticationManager.manager.loginWith(credentials: credentials)
        task.upon(.main, execute: { [weak self] (result) in
            guard let `self` = self else { return }
            let title: String
            let message: String
            switch result {
            case .failure(let error):
                title = "Error"
                message = error.localizedDescription
            case .success(let loginResponse):
                title = "Success"
                message = """
                Login token is: \(loginResponse.authToken),
                approved scopes: \(SocialAuthenticationManager.FacebookCredentials.scopeFrom(strings: loginResponse.approvedPermissions))"
                """
            }

            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(action)

            self.present(controller, animated: true, completion: nil)
        })
    }
}
