//
//  Created by Pierluigi Cifani on 22/02/2018.
//

import UIKit
import SafariServices
import Deferred

public protocol SocialAuthenticationCredentials {
    var urlRequest: URL { get }
    func extractTokenFrom(URLCallback: URL) -> String?
}

@available (iOS 11, *)
public class SocialAuthenticationManager {

    static public let manager = SocialAuthenticationManager()
    private var authSession: SFAuthenticationSession?

    public func loginWith(credentials: SocialAuthenticationCredentials) -> Task<String> {
        let deferred = Deferred<Task<String>.Result>()
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
                let token = credentials.extractTokenFrom(URLCallback: url) else {
                deferred.fill(with: .failure(Error(title: "Unknown Response")))
                return
            }

            deferred.fill(with: .success(token))
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

        public struct Scope : OptionSet {
            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            public static let publicProfile  = Scope(rawValue: 1 << 0)
            public static let email  = Scope(rawValue: 1 << 1)
            public static let friends  = Scope(rawValue: 1 << 2)
            public static let birthday = Scope(rawValue: 1 << 3)
            public static let location  = Scope(rawValue: 1 << 4)
            public static let education  = Scope(rawValue: 1 << 5)
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

        var components = URLComponents()
        components.scheme = "https"
        components.host = "m.facebook.com"
        components.path = "/v2.11/dialog/oauth"

        let clientIDItem = URLQueryItem(name: "client_id", value: appID)
        let displayItem = URLQueryItem(name: "display", value: "touch")
        let redirectURIItem = URLQueryItem(name: "redirect_uri", value: redirectURI)

        components.queryItems = [clientIDItem, displayItem, redirectURIItem]
        return components.url!
    }

    public func extractTokenFrom(URLCallback: URL) -> String? {
        guard let components = URLComponents(url: URLCallback, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let code = queryItems.first(where: { return $0.name == "code" }),
            let codeValue = code.value else {
                return nil
        }
        return codeValue
    }
}

