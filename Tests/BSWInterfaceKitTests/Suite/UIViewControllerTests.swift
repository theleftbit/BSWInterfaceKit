
import BSWInterfaceKit
import BSWFoundation
import Testing
import UIKit

class UIViewControllerTests: BSWSnapshotTest {

    @Test
    func initialLayoutCallback() {
        let sut = TestViewController()
        self.rootViewController = sut
        #expect(sut.viewInitialLayoutDidCompleteCalled)
    }
    
    @Test
    func childViewController() {
        let parentVC = UIViewController()
        let childVC = UIViewController()
        parentVC.containViewController(childVC)
        #expect(parentVC.children.contains(childVC))
        parentVC.removeContainedViewController(childVC)
        #expect(!parentVC.children.contains(childVC))
    }
    
    @Test
    func addBottomActionButton() async {
        guard UIDevice.current.model != "iPad" else { return }
        let buttonHeight: CGFloat = 50
        let vc = bottomViewController(buttonHeight: buttonHeight)
        await verify(viewController: vc, testDarkMode: false)
        #expect(vc.button != nil)
        #expect(vc.containedViewController.view.safeAreaInsets.bottom == buttonHeight)
    }

    @Test
    func addBottomActionButtonWithMargin() async {
        guard UIDevice.current.model != "iPad" else { return }
        let buttonHeight: CGFloat = 50
        let padding: CGFloat = 20
        let vc = bottomViewController(margins: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding), buttonHeight: buttonHeight)
        await verify(viewController: vc, testDarkMode: false)
        #expect(vc.button != nil)
        #expect(vc.containedViewController.view.safeAreaInsets.bottom == (buttonHeight + padding))
    }

    @Test
    func addBottomController() async {
        let vc = bottomViewControllerContainer()
        await verify(viewController: vc, testDarkMode: false)
        #expect(vc.bottomController != nil)
        #expect(vc.containedViewController.bottomContainerViewController == vc)
    }
    
    @Test
    func addBottomActionButtonIntrinsicSizeCalculable() {
        
        let buttonHeight: CGFloat = 60
        let simulatedContentSize = CGSize(width: 320, height: 500)
        
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        let vc = BottomContainerViewController(
            containedViewController: ContentVC(size: simulatedContentSize),
            button: button
        )
        let constrainedHeight = vc.heightConstrainedTo(width: simulatedContentSize.width)
        #expect(constrainedHeight == simulatedContentSize.height + buttonHeight)
    }
    
    @Test
    func errorView() async {
        let vc = TestViewController()
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Retry"
        vc.showErrorMessage("Something Failed", error: SomeError(), retryButton: buttonConfig)
        await verify(viewController: vc, testDarkMode: false)
    }
    
    @Test
    func loadingView() async {
        let vc = TestViewController()
        vc.showLoadingView(UIViewControllerTests.loadingView())
        await verify(viewController: vc, testDarkMode: false)
    }

    @MainActor
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

@MainActor
private func bottomViewController(margins: UIEdgeInsets = .zero, buttonHeight: CGFloat) -> BottomContainerViewController {
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

@MainActor
private func bottomViewControllerContainer() -> BottomContainerViewController {
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
