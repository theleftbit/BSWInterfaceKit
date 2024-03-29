#if canImport(UIKit)

import BSWInterfaceKit
import BSWFoundation
import XCTest

class UIViewControllerTests: BSWSnapshotTest {

    func testInitialLayoutCallback() {
        let sut = TestViewController()
        rootViewController = sut
        let exp = expectation(description: "Layout the view and wait for it")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            exp.fulfill()
        }
        let _ = waiter.wait(for: [exp], timeout: 1)
        XCTAssert(sut.viewInitialLayoutDidCompleteCalled)
    }
    
    func testChildViewController() {
        let parentVC = UIViewController()
        let childVC = UIViewController()
        parentVC.containViewController(childVC)
        XCTAssert(parentVC.children.contains(childVC))
        parentVC.removeContainedViewController(childVC)
        XCTAssert(!parentVC.children.contains(childVC))
    }
    
    func testAddBottomActionButton() {
        guard UIDevice.current.model != "iPad" else { return }
        let buttonHeight: CGFloat = 50
        let vc = bottomViewController(buttonHeight: buttonHeight)
        waitABitAndVerify(viewController: vc, testDarkMode: false)
        XCTAssertNotNil(vc.button)
        XCTAssert(vc.containedViewController.view.safeAreaInsets.bottom == buttonHeight)
    }

    func testAddBottomActionButtonWithMargin() {
        guard UIDevice.current.model != "iPad" else { return }
        let buttonHeight: CGFloat = 50
        let padding: CGFloat = 20
        let vc = bottomViewController(margins: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding), buttonHeight: buttonHeight)
        waitABitAndVerify(viewController: vc, testDarkMode: false)
        XCTAssertNotNil(vc.button)
        XCTAssert(vc.containedViewController.view.safeAreaInsets.bottom == (buttonHeight + padding))
    }

    func testAddBottomController() {
        let vc = bottomViewControllerContainer()
        waitABitAndVerify(viewController: vc, testDarkMode: false)
        XCTAssertNotNil(vc.bottomController)
        XCTAssert(vc.containedViewController.bottomContainerViewController == vc)
    }
    
    func testAddBottomActionButtonIntrinsicSizeCalculable() {
        
        let buttonHeight: CGFloat = 60
        let simulatedContentSize = CGSize(width: 320, height: 500)
        
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        let vc = BottomContainerViewController(
            containedViewController: ContentVC(size: simulatedContentSize),
            button: button
        )
        let constrainedHeight = vc.heightConstrainedTo(width: simulatedContentSize.width)
        XCTAssert(constrainedHeight == simulatedContentSize.height + buttonHeight)
    }
    
    func testErrorView() {
        let vc = TestViewController()
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Retry"
        vc.showErrorMessage("Something Failed", error: "Some Error", retryButton: buttonConfig)
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
    
    func testLoadingView() {
        let vc = TestViewController()
        vc.showLoadingView(UIViewControllerTests.loadingView())
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }

    static func loadingView() -> UIView {
        // This is a dummy black box to aid snapshot tests
        // because since UIActivityControllers move,
        // they're hard to unit test
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 20),
            view.heightAnchor.constraint(equalToConstant: 20),
            ])
        view.backgroundColor = .black
        let containerView = UIView()
        containerView.addSubview(view)
        view.centerInSuperview()
        return containerView
    }
}

//MARK: Mock VCs

@objc(TestViewController)
private class TestViewController: UIViewController {
    
    var viewInitialLayoutDidCompleteCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewInitialLayoutDidComplete() {
        super.viewInitialLayoutDidComplete()
        viewInitialLayoutDidCompleteCalled = true
    }
}

func bottomViewController(margins: UIEdgeInsets = .zero, buttonHeight: CGFloat) -> BottomContainerViewController {
    let containedViewController = TestViewController()
    var config = UIButton.Configuration.filled()
    config.title = "Send Wink"
    config.baseForegroundColor = .white
    config.baseBackgroundColor = .red
    config.background.cornerRadius = 0
    let button = UIButton(configuration: config)
    button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    return BottomContainerViewController(containedViewController: containedViewController, button: button, margins: margins)
}

func bottomViewControllerContainer() -> BottomContainerViewController {
    @objc(BSWInterfaceKitTestsTopVC)
    class TopVC: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
        }
    }
    
    @objc(BSWInterfaceKitTestsBottomVC)
    class BottomVC: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .darkGray
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.addArrangedSubview({
                var config = UIButton.Configuration.plain()
                config.title = "❤️"
                return UIButton(configuration: config)
            }())
            stackView.addArrangedSubview({
                var config = UIButton.Configuration.plain()
                config.title = "🇪🇸"
                return UIButton(configuration: config)
                }())
            stackView.addArrangedSubview({
                var config = UIButton.Configuration.plain()
                config.title = "🚀"
                return UIButton(configuration: config)
                }())
            view.addAutolayoutSubview(stackView)
            stackView.pinToSuperview()
        }
    }
    return BottomContainerViewController(
        containedViewController: TopVC(),
        bottomViewController: BottomVC()
    )
}

private class ContentVC: UIViewController {
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func loadView() {
        view = UIView()
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
}

extension String: LocalizedError {

}

#endif
