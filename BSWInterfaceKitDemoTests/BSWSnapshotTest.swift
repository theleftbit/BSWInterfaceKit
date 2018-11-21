//
//  Created by Pierluigi Cifani on 12/02/2017.
//

import XCTest
import FBSnapshotTestCase
@testable import BSWInterfaceKit

class BSWSnapshotTest: FBSnapshotTestCase {

    let waiter = XCTWaiter()

    override func setUp() {
        super.setUp()
            
        // Set snapshot device agnostic. It will append "iPhone" to the snapshot filename
        agnosticOptions = [.device, .OS, .screenSize]

        // Disable downloading images from web to avoid flaky tests.
        UIImageView.disableWebDownloads()
        RandomColorFactory.isOn = false
    }

    var currentWindow: UIWindow {
        return UIApplication.shared.keyWindow!
    }

    var rootViewController: UIViewController? {
        get {
            return currentWindow.rootViewController
        }

        set(newRootViewController) {
            currentWindow.rootViewController = newRootViewController
            currentWindow.makeKeyAndVisible()
        }
    }

    /// Add the view controller on the window and wait infinitly
    func debug(viewController: UIViewController) {
        rootViewController = viewController
        let exp = expectation(description: "No expectation")
        let _ = waiter.wait(for: [exp], timeout: 1000)
    }
    
    func debug(view: UIView) {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.view.addSubview(view)
        debug(viewController: vc)
    }

    /// Presents the VC using a fresh rootVC in the host's main window.
    /// - note: This method blocks the calling thread until the presentation is finished.
    func presentViewController(_ viewController: UIViewController) {
        let exp = expectation(description: "Presentation")
        rootViewController = UIViewController()
        rootViewController!.view.backgroundColor = .white // I just think it looks pretier this way
        rootViewController!.present(viewController, animated: true, completion: {
            exp.fulfill()
        })
        let _ = waiter.wait(for: [exp], timeout: 10)
    }

    func waitABitAndVerify(viewController: UIViewController) {
        rootViewController = viewController
        waitABitAndVerify(view: viewController.view)
    }

    func waitABitAndVerify(view: UIView) {

        view.setNeedsLayout()
        view.layoutIfNeeded()

        if let scrollView = view as? UIScrollView, agnosticOptions == [.none] {
            scrollView.frame = CGRect(
                x: scrollView.frame.origin.x,
                y: scrollView.frame.origin.y,
                width: scrollView.contentSize.width,
                height: scrollView.contentSize.height
            )
        }

        let exp = expectation(description: "verify view")
        let deadlineTime = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.FBSnapshotVerifyView(view, tolerance: 0.1)
            exp.fulfill()
        }
        let _ = waiter.wait(for: [exp], timeout: 1)
    }
}
