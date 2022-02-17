//
//  Created by Pierluigi Cifani on 22/02/2018.
//

#if os(iOS)

import UIKit
import SafariServices
import Deferred
import AuthenticationServices

public protocol SocialAuthenticationCredentials {
    func createURLRequest(isSafariVC: Bool) -> URL
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

public class SocialAuthenticationManager: NSObject {
    
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
     
     - returns: A Task with the response from the O-Auth service
     */
    public func loginWith(credentials: SocialAuthenticationCredentials, fromVC: UIViewController) async throws -> LoginResponse {
        guard self.authSession == nil else {
            throw SocialAuthenticationError.ongoingLogin
        }
        
        return try await withCheckedThrowingContinuation { cont in
            let authSession = ASWebAuthenticationSession(url: credentials.createURLRequest(isSafariVC: false), callbackURLScheme: nil) { (url, error) in
                defer { self.authSession = nil }
                guard error == nil else {
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
    }
}

#endif
