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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        themeApp()
        if let _ = NSClassFromString("XCTest") {
            window?.rootViewController = UIViewController()
        }
        else {
            window?.rootViewController = SplitViewController(masterViewController: FeaturesViewController())
        }
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }

    
    func themeApp() {
        UIImageView.fadeImageDuration = 0.33
        StateContainerAppereance.transitionConfiguration = .simple()
    }
}
