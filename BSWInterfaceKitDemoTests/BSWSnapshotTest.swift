//
//  Created by Pierluigi Cifani on 12/02/2017.
//

import XCTest
import SnapshotTesting
import BSWInterfaceKit

extension String: LocalizedError {

}

class BSWSnapshotTest: XCTestCase {

    let waiter = XCTWaiter()

    var recordMode = false
    
    override func setUp() {
        super.setUp()

        // Disable downloading images from web to avoid flaky tests.
        UIImageView.disableWebDownloads()
        RandomColorFactory.isOn = false
    }

    private var currentWindow: UIWindow {
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

    func waitABitAndVerify(viewController: UIViewController, file: StaticString = #file, testName: String = #function) {
        rootViewController = viewController
        
        let exp = expectation(description: "verify view")
        let deadlineTime = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let screenSize = UIScreen.main.bounds
            let currentSimulatorSize = "\(Int(screenSize.width))x\(Int(screenSize.height))"
            assertSnapshot(matching: viewController, as: .image(on: UIScreen.main.currentDevice), named: currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
            exp.fulfill()
        }
        let _ = waiter.wait(for: [exp], timeout: 1)
    }

    func verify(view: UIView, file: StaticString = #file, testName: String = #function) {

        view.setNeedsLayout()
        view.layoutIfNeeded()

        if let scrollView = view as? UIScrollView {
            scrollView.frame = CGRect(
                x: scrollView.frame.origin.x,
                y: scrollView.frame.origin.y,
                width: scrollView.contentSize.width,
                height: scrollView.contentSize.height
            )
        }

        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(matching: view, as: .image, named: "\(currentSimulatorScale)x", record: self.recordMode, file: file, testName: testName)
    }
}

private extension UIScreen {
    var currentDevice: ViewImageConfig {
        switch self.bounds.size {
        case CGSize(width: 320, height: 568):
            return .iPhoneSe
        case CGSize(width: 375, height: 667):
            return .iPhone8
        case CGSize(width: 414, height: 736):
            return .iPhone8Plus
        case CGSize(width: 375, height: 812):
            return .iPhoneX
        case CGSize(width: 414, height: 896):
            return .iPhoneXsMax
        case CGSize(width: 768, height: 1024):
            return .iPadMini(.portrait)
        default:
            return .iPhoneX
        }
    }
}

