#if canImport(UIKit)
/*
import BSWInterfaceKit
import BSWFoundation
import XCTest

class UIViewControllerTaskTests: BSWSnapshotTest {
    
    private var originalLoadingViewFactory: UIViewController.LoadingViewFactory!
    private var originalErrorViewFactory: UIViewController.ErrorViewFactory!

    override init() {
        originalLoadingViewFactory = UIViewController.loadingViewFactory
        originalErrorViewFactory = UIViewController.errorViewFactory
        UIViewController.loadingViewFactory = { UIViewControllerTests.loadingView() }
        super.init()
    }
    
    deinit {
        MainActor.assumeIsolated {
            UIViewController.loadingViewFactory = originalLoadingViewFactory
            UIViewController.errorViewFactory = originalErrorViewFactory
        }
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
    
    func testTaskLoadingView() async {
        let vc = MockVC(taskGenerator: {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            return ""
        })
        await waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskErrorView() async {
        let vc = MockVC(taskGenerator: { throw SomeError() })
        await waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskSuccessView() async {
        let vc = MockVC(taskGenerator: { return "Cachondo" })
        await waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}
 */
#endif
