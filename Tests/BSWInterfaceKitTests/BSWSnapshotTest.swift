
import Testing
import SnapshotTesting
import BSWInterfaceKit
import UIKit

/// Convenience class to ease snapshot testing
@MainActor
open class BSWSnapshotTest {

    public let defaultWidth: CGFloat = 375
    public var recordMode = false
    public var waitStrategy: WaitStrategy = .milliseconds(50)
    
    public enum WaitStrategy {
        case closestBSWTask
        case milliseconds(Double)
    }
    
    let defaultPerceptualPrecision: Float = 0.997

    init() {
        recordMode = true
        
        // Disable downloading images from web to avoid flaky tests.
        UIImageView.disableWebDownloads()
        RandomColorFactory.isOn = false
        RandomColorFactory.defaultColor = UIColor.init(r: 255, g: 149, b: 0)
    }

    private let currentWindow = UIWindow()

    public var rootViewController: UIViewController? {
        get {
            return currentWindow.rootViewController
        }
        set(newRootViewController) {
            currentWindow.rootViewController = newRootViewController
            currentWindow.makeKeyAndVisible()
            currentWindow.setNeedsLayout()
            currentWindow.layoutIfNeeded()
        }
    }

    /// Add the view controller on the window and wait infinitly
    public func debug(viewController: UIViewController) async {
        rootViewController = viewController
        if #available(iOS 16.0, *) {
            try? await Task.sleep(for: .seconds(1000))
        }
    }

    public func debug(view: UIView) async {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.view.addSubview(view)
        await debug(viewController: vc)
    }
    
    /// Sets this VC as the rootVC of the current window and snapshots it after some time.
    /// - note: Use this method if you're VC fetches some data asynchronously, but mock that dependency.
    public func verify(viewController: UIViewController, testDarkMode: Bool = true, file: StaticString = #filePath, testName: String = #function) async {

        rootViewController = viewController

        switch waitStrategy {
        case .closestBSWTask:
            if let task = viewController.closestBSWFetchTask {
                await task.value
            }
        case .milliseconds(let double):
            if #available(iOS 16.0, *) {
                try? await Task.sleep(for: .milliseconds(double))
            }
        }
        
        let strategy: Snapshotting = .image(
            on: UIScreen.main.currentDevice,
            perceptualPrecision: defaultPerceptualPrecision
        )

        self.rootViewController = nil
        
        let screenSize = UIScreen.main.bounds
        let currentSimulatorSize = "\(Int(screenSize.width))x\(Int(screenSize.height))"
        assertSnapshot(of: viewController, as: strategy, named: currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
        if testDarkMode {
            viewController.overrideUserInterfaceStyle = .dark
            assertSnapshot(of: viewController, as: strategy, named: "Dark" + currentSimulatorSize, record: self.recordMode, file: file, testName: testName)
        }
    }

    /// Snapshots the passed view.
    /// - note: Remember to set the `frame` or `intrinsicContentSize` for the passed view.
    public func verify(view: UIView, file: StaticString = #filePath, testName: String = #function) {
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(of: view, as: .image, named: "\(currentSimulatorScale)x", record: self.recordMode, file: file, testName: testName)
    }

    /// Snapshots the entire scrollView's `contentSize`
    public func verify(scrollView: UIScrollView, file: StaticString = #filePath, testName: String = #function) {
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

    public func verify(attributedString: NSAttributedString, file: StaticString = #filePath, testName: String = #function) {
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(of: attributedString, as: .image, named: "\(currentSimulatorScale)x", file: file, testName: testName)
    }
   
    public func verify<View: ViewModelConfigurable & UIViewController>(viewController: View, vm: View.VM, file: StaticString = #filePath, testName: String = #function) {
        viewController.configureFor(viewModel: vm)
        let estimatedSize = viewController.view.systemLayoutSizeFitting(
            CGSize(width: defaultWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        viewController.view.frame.size = estimatedSize
        verify(view: viewController.view, file: file, testName: testName)
    }

    public func verify<View: ViewModelConfigurable & UIView>(view: View, vm: View.VM, file: StaticString = #filePath, testName: String = #function) {
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
    @MainActor
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
