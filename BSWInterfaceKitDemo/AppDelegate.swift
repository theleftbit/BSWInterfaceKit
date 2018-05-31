//
//  Created by Pierluigi Cifani on 12/02/2017.
//
//

import UIKit
import BSWInterfaceKit
import BSWFoundation
import Deferred

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let _ = NSClassFromString("XCTest") {
            window?.rootViewController = UIViewController()
        }
        else {
            window?.rootViewController = UINavigationController(rootViewController: FeaturesViewController())
        }
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        SocialAuthenticationManager.manager.handleApplicationDidOpenURL(url, options: options)
        return true
    }

}

