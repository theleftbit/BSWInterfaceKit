//
//  Created by Pierluigi Cifani on 22/02/2018.
//

 #if os(iOS)

import UIKit
import SafariServices
import Deferred
import Task
import AuthenticationServices
 
public protocol SocialAuthenticationCredentials {
    func createURLRequest(isSafariVC: Bool) -> URL
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

 public class SocialAuthenticationManager {

    static public let manager = SocialAuthenticationManager()
    private var authSession: ASWebAuthenticationSession?

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
     */
    public func loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        return safariAuthSession_loginWith(credentials: credentials)
    }

    private func safariAuthSession_loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        let deferred = Deferred<Task<LoginResponse>.Result>()
        guard self.authSession == nil else {
            deferred.fill(with: .failure(SocialAuthenticationError.ongoingLogin))
            return Task(deferred)
        }

        let authSession = ASWebAuthenticationSession(url: credentials.createURLRequest(isSafariVC: false), callbackURLScheme: nil) { (url, error) in
            defer { self.authSession = nil }
            guard error == nil else {
                deferred.fill(with: .failure(error!))
                return
            }

            guard let url = url, let response = credentials.extractResponseFrom(URLCallback: url) else {
                deferred.fill(with: .failure(SocialAuthenticationError.unknownResponse))
                return
            }
            
            deferred.fill(with: .success(response))
        }

        authSession.start()

        self.authSession = authSession
        return Task(deferred)
    }
}

 extension SocialAuthenticationManager {

    public enum SocialAuthenticationError: Swift.Error {
        case unknownResponse
        case ongoingLogin
    }
}

#endif
