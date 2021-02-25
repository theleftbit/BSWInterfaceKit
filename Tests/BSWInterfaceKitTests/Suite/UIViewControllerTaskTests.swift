
import BSWInterfaceKit
import BSWFoundation
import XCTest
import Task

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
        
        let taskGenerator: (() -> Task<String>)
        
        init(taskGenerator: @escaping (() -> Task<String>)) {
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
        let vc = MockVC(taskGenerator: { .never })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskErrorView() {
        let vc = MockVC(taskGenerator: { .init(failure: "Some Error") })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    func testTaskSuccessView() {
        let vc = MockVC(taskGenerator: { .init(success: "Cachondo") })
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}
