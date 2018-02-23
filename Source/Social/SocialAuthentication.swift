//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import SafariServices
import Deferred

@available (iOS 11, *)
public protocol SocialAuthenticationCredentials {
    var urlRequest: URL { get }
    func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse?
}

@available (iOS 11, *)
public class SocialAuthenticationManager {

    static public let manager = SocialAuthenticationManager()
    private var authSession: SFAuthenticationSession?

    public struct LoginResponse {
        public let authToken: String
        public let approvedPermissions: Set<String>
        public let rejectedPermissions: Set<String>
    }

    public func loginWith(credentials: SocialAuthenticationCredentials) -> Task<LoginResponse> {
        let deferred = Deferred<Task<LoginResponse>.Result>()
        guard self.authSession == nil else {
            deferred.fill(with: .failure(Error(title: "Ongoing login")))
            return Task(deferred)
        }

        let authSession = SFAuthenticationSession(url: credentials.urlRequest, callbackURLScheme: nil) { (url, error) in
            defer { self.authSession = nil }
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

        self.authSession = authSession
        return Task(deferred)
    }
}

@available (iOS 11, *)
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

    public struct Error: Swift.Error {
        let title: String
    }
}

@available (iOS 11, *)
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

