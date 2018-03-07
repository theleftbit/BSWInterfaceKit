//
//  Created by Pierluigi Cifani on 23/02/2018.
//

import Foundation

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
}

extension SocialAuthenticationManager.FacebookCredentials: SocialAuthenticationCredentials {

    public func createURLRequest(isSafariVC: Bool) -> URL {

        let redirectURI = "fb\(appID)://authorize/"
        guard UIApplication.shared.canOpenURL(URL(string: redirectURI)!) else {
            fatalError("Please add this URL Scheme")
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: appID),
            URLQueryItem(name: "display", value: "touch"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "token")
        ]

        if !self.scope.isEmpty {
            queryItems.append(URLQueryItem(name: "return_scopes", value: "true"))
            queryItems.append(URLQueryItem(name: "scope", value: SocialAuthenticationManager.FacebookCredentials.printableScope(self.scope).joined(separator: ",")))
        }

        if isSafariVC {
            queryItems.append(URLQueryItem(name: "sfvc", value: "1"))
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "m.facebook.com"
        components.path = "/v2.11/dialog/oauth"
        components.queryItems = queryItems
        return components.url!
    }

    public func extractResponseFrom(URLCallback: URL) -> SocialAuthenticationManager.LoginResponse? {

        var modifiedURL = URLCallback
        if let range = modifiedURL.absoluteString.range(of: "authorize/#") {
            let patchedString = modifiedURL.absoluteString.replacingCharacters(in: range, with: "authorize/?")
            modifiedURL = URL(string: patchedString) ?? modifiedURL
        }

        guard let components = URLComponents(url: modifiedURL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let token = queryItems.first(where: { return $0.name == "access_token" }),
            let tokenValue = token.value else {
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
            authToken: tokenValue,
            approvedPermissions: Set(approvedPermissions),
            rejectedPermissions: Set(rejectedPermissions)
        )
    }
}
