#if canImport(UIKit)

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

    private let currentWindow = UIWindow()

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
            self.rootViewController = nil
            
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
    
    func verify<View: ViewModelConfigurable & UIViewController>(viewController: View, vm: View.VM, file: StaticString = #file, testName: String = #function) {
        viewController.configureFor(viewModel: vm)
        let estimatedSize = viewController.view.systemLayoutSizeFitting(
            CGSize(width: 375, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        viewController.view.frame.size = estimatedSize
        verify(view: viewController.view, file: file, testName: testName)
    }

    func verify<View: ViewModelConfigurable & UIView>(view: View, vm: View.VM, file: StaticString = #file, testName: String = #function) {
        view.configureFor(viewModel: vm)
        
        /// First, set a ridiculous frame and do a fake layout pass.
        /// Some views seem to need this to get their shit togheter
        /// before calling `systemLayoutSizeFitting`
        view.frame = .init(origin: .zero, size: .init(width: 375, height: 5000))
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let estimatedSize = view.systemLayoutSizeFitting(
            CGSize(width: 375, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.frame.size = estimatedSize
        verify(view: view, file: file, testName: testName)
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

#endif
