#if canImport(UIKit)

import BSWInterfaceKit
import BSWFoundation
import XCTest

@available(iOS 15, *)
class UIViewControllerTaskTests: BSWSnapshotTest {
    
    private var originalLoadingViewFactory: UIViewController.LoadingViewFactory!
    private var originalErrorViewFactory: UIViewController.ErrorViewFactory!

    override func setUp() {
        super.setUp()
        originalLoadingViewFactory = UIViewController.loadingViewFactory
        originalErrorViewFactory = UIViewController.errorViewFactory
        UIViewController.loadingViewFactory = { UIViewControllerTests.loadingView() }
    }
    
    override func tearDown() {
        super.tearDown()
        UIViewController.loadingViewFactory = originalLoadingViewFactory
        UIViewController.errorViewFactory = originalErrorViewFactory
    }
    
    class MockVC: UIViewController {
        
        let taskGenerator: UIViewController.SwiftConcurrencyGenerator<String>
        
        init(taskGenerator: @escaping UIViewController.SwiftConcurrencyGenerator<String>) {
            self.taskGenerator = taskGenerator
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let label = UILabel()
            view.addSubview(label)
            label.centerInSuperview()
            fetchData(taskGenerator: taskGenerator) { (string) in
                label.text = string
            }
        }
    }
    
    func testTaskLoadingView() {
        let vc = MockVC(taskGenerator: {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            return ""
        })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskErrorView() {
        let vc = MockVC(taskGenerator: { throw "Some Error" })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskSuccessView() {
        let vc = MockVC(taskGenerator: { return "Cachondo" })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}
#endif
