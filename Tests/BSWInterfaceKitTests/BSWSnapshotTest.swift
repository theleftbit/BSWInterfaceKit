#if canImport(UIKit)

import XCTest
import SnapshotTesting
import BSWInterfaceKit

/// XCTestCase subclass to ease snapshot testing
open class BSWSnapshotTest: XCTestCase {

    public let waiter = XCTWaiter()
    public let defaultWidth: CGFloat = 375
    public var recordMode = false
    let defaultPerceptualPrecision: Float = 0.997

    open override func setUp() {
        super.setUp()
        
        // Disable downloading images from web to avoid flaky tests.
        UIImageView.disableWebDownloads()
        RandomColorFactory.isOn = false
        
        if let value = ProcessInfo.processInfo.environment["GENERATE_SNAPSHOTS"], value == "1" {
            recordMode = true
        }
    }

    private let currentWindow = UIWindow()

    public var rootViewController: UIViewController? {
        get {
            return currentWindow.rootViewController
        }

        set(newRootViewController) {
            currentWindow.rootViewController = newRootViewController
            currentWindow.makeKeyAndVisible()
        }
    }

    /// Add the view controller on the window and wait infinitly
    public func debug(viewController: UIViewController) {
        rootViewController = viewController
        let exp = expectation(description: "No expectation")
        let _ = waiter.wait(for: [exp], timeout: 1000)
    }
    
    public func debug(view: UIView) {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.view.addSubview(view)
        debug(viewController: vc)
    }

    /// Presents the VC using a fresh rootVC in the host's main window.
    /// - note: This method blocks the calling thread until the presentation is finished.
    public func presentViewController(_ viewController: UIViewController) {
        let exp = expectation(description: "Presentation")
        rootViewController = UIViewController()
        rootViewController!.view.backgroundColor = .white // I just think it looks pretier this way
        rootViewController!.present(viewController, animated: true, completion: {
            exp.fulfill()
        })
        let _ = waiter.wait(for: [exp], timeout: 10)
    }
    
    @MainActor
    public func waitTaskAndVerify(viewController: UIViewController, testDarkMode: Bool = true, file: StaticString = #file, testName: String = #function) async {
        rootViewController = viewController
        
        let strategy: Snapshotting = .image(
            on: UIScreen.main.currentDevice,
            perceptualPrecision: defaultPerceptualPrecision
        )

        guard let task = viewController.fetchTask else {
            XCTFail()
            return
        }
        await task.value
        let screenSize = UIScreen.main.bounds
        let currentSimulatorSize = "\(Int(screenSize.width))x\(Int(screenSize.height))"
        assertSnapshot(matching: viewController, as: strategy, named: currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
        if testDarkMode {
            viewController.overrideUserInterfaceStyle = .dark
            assertSnapshot(matching: viewController, as: strategy, named: "Dark" + currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
        }
    }

    /// Sets this VC as the rootVC of the current window and snapshots it after some time.
    /// - note: Use this method if you're VC fetches some data asynchronously, but mock that dependency.
    public func waitABitAndVerify(viewController: UIViewController, testDarkMode: Bool = true, file: StaticString = #file, testName: String = #function) {
        rootViewController = viewController
        
        let strategy: Snapshotting = .image(
            on: UIScreen.main.currentDevice,
            perceptualPrecision: defaultPerceptualPrecision
        )

        let exp = expectation(description: "verify view")
        let deadlineTime = DispatchTime.now() + .milliseconds(50)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.rootViewController = nil
            
            let screenSize = UIScreen.main.bounds
            let currentSimulatorSize = "\(Int(screenSize.width))x\(Int(screenSize.height))"
            assertSnapshot(matching: viewController, as: strategy, named: currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
            if testDarkMode {
                viewController.overrideUserInterfaceStyle = .dark
                assertSnapshot(matching: viewController, as: strategy, named: "Dark" + currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
            }
            exp.fulfill()
        }
        let _ = waiter.wait(for: [exp], timeout: 1)
    }

    /// Snapshots the passed view.
    /// - note: Remember to set the `frame` or `intrinsicContentSize` for the passed view.
    public func verify(view: UIView, file: StaticString = #file, testName: String = #function) {
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(matching: view, as: .image, named: "\(currentSimulatorScale)x", record: self.recordMode, file: file, testName: testName)
    }

    /// Snapshots the entire scrollView's `contentSize`
    public func verify(scrollView: UIScrollView, file: StaticString = #file, testName: String = #function) {
        /// First, set a ridiculous frame and do a fake layout pass.
        /// Some views seem to need this to get their shit togheter
        /// before calling `systemLayoutSizeFitting`
        scrollView.frame = .init(origin: .zero, size: .init(width: defaultWidth, height: 5000))
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.frame = CGRect(
            x: scrollView.frame.origin.x,
            y: scrollView.frame.origin.y,
            width: scrollView.contentSize.width,
            height: scrollView.contentSize.height
        )
        verify(view: scrollView, file: file, testName: testName)
    }

    public func verify(attributedString: NSAttributedString, file: StaticString = #file, testName: String = #function) {
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(matching: attributedString, as: .image, named: "\(currentSimulatorScale)x", file: file, testName: testName)
    }
   
    public func verify<View: ViewModelConfigurable & UIViewController>(viewController: View, vm: View.VM, file: StaticString = #file, testName: String = #function) {
        viewController.configureFor(viewModel: vm)
        let estimatedSize = viewController.view.systemLayoutSizeFitting(
            CGSize(width: defaultWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        viewController.view.frame.size = estimatedSize
        verify(view: viewController.view, file: file, testName: testName)
    }

    public func verify<View: ViewModelConfigurable & UIView>(view: View, vm: View.VM, file: StaticString = #file, testName: String = #function) {
        view.configureFor(viewModel: vm)
        
        /// First, set a ridiculous frame and do a fake layout pass.
        /// Some views seem to need this to get their shit togheter
        /// before calling `systemLayoutSizeFitting`
        view.frame = .init(origin: .zero, size: .init(width: defaultWidth, height: 5000))
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let estimatedSize = view.systemLayoutSizeFitting(
            CGSize(width: defaultWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        view.frame.size = estimatedSize
        verify(view: view, file: file, testName: testName)
    }
    
    public func verify<View: IntrinsicSizeCalculable & UIViewController>(viewController: View, file: StaticString = #file, testName: String = #function) {
        let estimatedHeight = viewController.heightConstrainedTo(width: defaultWidth)
        viewController.view.frame.size = .init(width: defaultWidth, height: estimatedHeight)
        verify(view: viewController.view, file: file, testName: testName)
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
        case CGSize(width: 390, height: 844):
            return .iPhone12
        case CGSize(width: 414, height: 896):
            return .iPhoneXr
        case CGSize(width: 768, height: 1024):
            return .iPadMini(.portrait)
        default:
            return .iPhoneX
        }
    }
}


extension Snapshotting where Value == NSAttributedString, Format == UIImage {
    public static let image: Snapshotting = Snapshotting<UIView, UIImage>.image.pullback { string in
        let label = UILabel()
        label.attributedText = string
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.frame.size = label.systemLayoutSizeFitting(
            CGSize(width: 300, height: 0),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .defaultLow
        )
        return label
    }
}

#endif
