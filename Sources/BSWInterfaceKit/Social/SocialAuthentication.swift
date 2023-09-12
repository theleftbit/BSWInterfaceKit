//
//  Created by Pierluigi Cifani on 22/02/2018.
//

#if os(iOS)

import UIKit
import SafariServices
import AuthenticationServices

/// This protocol abstracts how to talk with an O-Auth provider
public protocol SocialAuthenticationCredentials {
    /// Create a URL to perform the authentication on
    /// - Parameter isSafariVC: Wheter Safari View Controller will be used.
    /// - Returns: The URL to call.
    func createURLRequest(isSafariVC: Bool) -> URL
    
    /// Extract the response that the O-Auth provider from the URL Callback
    /// - Parameter URLCallback: the URL Callback
    /// - Returns: The Response if it was possible to parse.
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

/// This class allows you to integrate with social networks to authenticate a user.
public class SocialAuthenticationManager: NSObject {
    
    /// A shared manager.
    static public let manager = SocialAuthenticationManager()
    private var authSession: ASWebAuthenticationSession?
    private weak var fromViewController: UIViewController?
    
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
     
     - returns: The response from the O-Auth service
     */
    public func loginWith(credentials: SocialAuthenticationCredentials, fromVC: UIViewController) async throws -> LoginResponse {
        guard self.authSession == nil else {
            throw SocialAuthenticationError.ongoingLogin
        }
        self.fromViewController = fromVC
        return try await withCheckedThrowingContinuation { cont in
            let authSession = ASWebAuthenticationSession(url: credentials.createURLRequest(isSafariVC: false), callbackURLScheme: nil) { (url, error) in
                defer {
                    self.authSession = nil
                    self.fromViewController = nil
                }
                guard error == nil else {
                    if let asWebError = error as? ASWebAuthenticationSessionError,
                       asWebError.errorCode == ASWebAuthenticationSessionError.Code.canceledLogin.rawValue {
                        cont.resume(throwing: SocialAuthenticationError.userCanceled)
                        return
                    }
                    
                    cont.resume(throwing: error!)
                    return
                }
                
                guard let url = url, let response = credentials.extractResponseFrom(URLCallback: url) else {
                    cont.resume(throwing: SocialAuthenticationError.unknownResponse)
                    return
                }
                
                cont.resume(returning: response)
            }
            authSession.presentationContextProvider = self
            authSession.start()
            self.authSession = authSession
       }
    }
}

extension SocialAuthenticationManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        fromViewController?.view.window ?? UIWindow()
    }
}

extension SocialAuthenticationManager {
    
    public enum SocialAuthenticationError: Swift.Error {
        case unknownResponse
        case ongoingLogin
        case userCanceled
        case emailNotProvided
    }
}

#endif
