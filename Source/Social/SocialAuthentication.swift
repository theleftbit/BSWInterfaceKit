//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import SafariServices
import Deferred

public protocol SocialAuthenticationCredentials {
    func createURLRequest(isSafariVC: Bool) -> URL
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

public class SocialAuthenticationManager {

    static public let manager = SocialAuthenticationManager()
    private var currentRequest: CurrentRequest?

    public struct LoginResponse {
        public let authToken: String
        public let approvedPermissions: Set<String>
        public let rejectedPermissions: Set<String>
        public init(authToken: String, approvedPermissions: Set<String> = [], rejectedPermissions: Set<String> = []) {
            self.authToken = authToken
            self.approvedPermissions = approvedPermissions
            self.rejectedPermissions = rejectedPermissions
        }
    }

    /**
     Performs O-Auth login using the provided credentials. The framework
     provides FB support, but you can extend it as you wish.

     - parameter credentials: The credentials used to login

     - returns: A Task with the response from the O-Auth service

     - note: If you're targeting iOS 11+, then this is all you have to do, but
     for iOS 9 and 10, you should also call `handleApplicationDidOpenURL` from
     your app delegate.
     */
    public func loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        if #available(iOS 11, *) {
            return safariAuthSession_loginWith(credentials: credentials)
        } else {
            return safariViewController_loginWith(credentials: credentials)
        }
    }

    public func handleApplicationDidOpenURL(_ URL: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        guard let sourceApplication = options[.sourceApplication] as? String,
            sourceApplication == "com.apple.SafariViewService",
            let currentRequest = self.currentRequest,
            case .safariVC(let safariVC, let credentials, let deferred) = currentRequest else {
                return
        }

        safariVC.dismiss(animated: true, completion: nil)
        if let response = credentials.extractResponseFrom(URLCallback: URL) {
            deferred.fill(with: .success(response))
        } else {
            deferred.fill(with: .failure(Error(title: "Unknown Response")))
        }
        self.currentRequest = nil
    }

    @available (iOS 9, *)
    private func safariViewController_loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        let deferred = Deferred<Task<LoginResponse>.Result>()
        guard let visibleVC = UIApplication.shared.keyWindow?.visibleViewController else {
            deferred.fill(with: .failure(Error(title: "No visible VC")))
            return Task(deferred)
        }
        let safariVC = SFSafariViewController(url: credentials.createURLRequest(isSafariVC: true))
        safariVC.modalPresentationStyle = .overFullScreen
        visibleVC.present(safariVC, animated: false, completion: nil)

        self.currentRequest = .safariVC(safariVC, credentials, deferred)
        return Task(deferred)
    }

    @available (iOS 11, *)
    private func safariAuthSession_loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        let deferred = Deferred<Task<LoginResponse>.Result>()
        guard self.currentRequest == nil else {
            deferred.fill(with: .failure(Error(title: "Ongoing login")))
            return Task(deferred)
        }

        let authSession = SFAuthenticationSession(url: credentials.createURLRequest(isSafariVC: false), callbackURLScheme: nil) { (url, error) in
            defer { self.currentRequest = nil }
            guard error == nil else {
                deferred.fill(with: .failure(error!))
                return
            }

            guard let url = url,
                let response = credentials.extractResponseFrom(URLCallback: url) else {
                deferred.fill(with: .failure(Error(title: "Unknown Response")))
                return
            }

            deferred.fill(with: .success(response))
        }

        authSession.start()

        self.currentRequest = .authSession(authSession)
        return Task(deferred)
    }
}

extension SocialAuthenticationManager {

    private enum CurrentRequest {
        case authSession(NSObject)
        case safariVC(UIViewController, SocialAuthenticationCredentials, Deferred<Task<LoginResponse>.Result>)
    }

    public struct Error: Swift.Error {
        let title: String
    }
}
