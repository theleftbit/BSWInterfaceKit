//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import SafariServices
import Deferred

public protocol SocialAuthenticationCredentials {
    var urlRequest: URL { get }
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

public class SocialAuthenticationManager {

    static public let manager = SocialAuthenticationManager()
    private var currentRequest: CurrentRequest?

    public struct LoginResponse {
        public let authToken: String
        public let approvedPermissions: Set<String>
        public let rejectedPermissions: Set<String>
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

    public func handleApplicationDidOpenURL(_ URL: URL, options: [UIApplicationOpenURLOptionsKey : Any]) {
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
        guard var urlComponents = URLComponents(url: credentials.urlRequest, resolvingAgainstBaseURL: false) else {
            deferred.fill(with: .failure(Error(title: "Malformed URL")))
            return Task(deferred)
        }
        urlComponents.queryItems?.append(URLQueryItem(name: "sfvc", value: "1"))
        let safariVC = SFSafariViewController(url: urlComponents.url!)
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

        let authSession = SFAuthenticationSession(url: credentials.urlRequest, callbackURLScheme: nil) { (url, error) in
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

    public struct FacebookCredentials {
        public let appID: String
        public let scope: Scope

        public init(appID: String, scope: Scope = [.publicProfile]) {
            self.appID = appID
            self.scope = scope
        }

        static public func scopeFrom(strings: Set<String>) -> Scope {
            var scope = Scope()
            if strings.contains("public_profile") {
                scope.insert(.publicProfile)
            }
            if strings.contains("email") {
                scope.insert(.email)
            }
            if strings.contains("user_friends") {
                scope.insert(.friends)
            }
            if strings.contains("user_birthday") {
                scope.insert(.birthday)
            }
            if strings.contains("user_location") {
                scope.insert(.location)
            }
            if strings.contains("user_education_history") {
                scope.insert(.education)
            }
            return scope
        }

        static public func printableScope(_ scope: Scope) -> Set<String> {
            var allScopes = Set<String>()
            if scope.contains(.publicProfile) {
                allScopes.insert("public_profile")
            }
            if scope.contains(.email) {
                allScopes.insert("email")
            }
            if scope.contains(.friends) {
                allScopes.insert("user_friends")
            }
            if scope.contains(.birthday) {
                allScopes.insert("user_birthday")
            }
            if scope.contains(.location) {
                allScopes.insert("user_location")
            }
            if scope.contains(.education) {
                allScopes.insert("user_education_history")
            }
            return allScopes
        }

        public struct Scope: OptionSet, CustomDebugStringConvertible {
            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            public var debugDescription: String {
                return SocialAuthenticationManager.FacebookCredentials.printableScope(self).joined(separator: "&")
            }

            public static let publicProfile     = Scope(rawValue: 1 << 0)
            public static let email             = Scope(rawValue: 1 << 1)
            public static let friends           = Scope(rawValue: 1 << 2)
            public static let birthday          = Scope(rawValue: 1 << 3)
            public static let location          = Scope(rawValue: 1 << 4)
            public static let education         = Scope(rawValue: 1 << 5)
        }
    }

    private enum CurrentRequest {
        case authSession(NSObject)
        case safariVC(UIViewController, SocialAuthenticationCredentials, Deferred<Task<LoginResponse>.Result>)
    }

    public struct Error: Swift.Error {
        let title: String
    }
}

extension SocialAuthenticationManager.FacebookCredentials: SocialAuthenticationCredentials {

    public var urlRequest: URL {

        let redirectURI = "fb\(appID)://authorize/"
        guard UIApplication.shared.canOpenURL(URL(string: redirectURI)!) else {
            fatalError("Please add this URL Scheme")
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: appID),
            URLQueryItem(name: "display", value: "touch"),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]

        if !self.scope.isEmpty {
            queryItems.append(URLQueryItem(name: "return_scopes", value: "true"))
            queryItems.append(URLQueryItem(name: "scope", value: SocialAuthenticationManager.FacebookCredentials.printableScope(self.scope).joined(separator: ",")))
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "m.facebook.com"
        components.path = "/v2.11/dialog/oauth"
        components.queryItems = queryItems
        return components.url!
    }

    public func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse? {
        guard let components = URLComponents(url: URLCallback, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let code = queryItems.first(where: { return $0.name == "code" }),
            let codeValue = code.value else {
                return nil
        }

        let approvedPermissionsString = queryItems
            .first(where: { return $0.name == "granted_scopes" })?
            .value
        let rejectedPermissionsString = queryItems
            .first(where: { return $0.name == "denied_scopes" })?
            .value

        let approvedPermissions = approvedPermissionsString?.components(separatedBy: ",") ?? []
        let rejectedPermissions = rejectedPermissionsString?.components(separatedBy: ",") ?? []

        return SocialAuthenticationManager.LoginResponse(
            authToken: codeValue,
            approvedPermissions: Set(approvedPermissions),
            rejectedPermissions: Set(rejectedPermissions)
        )
    }
}

