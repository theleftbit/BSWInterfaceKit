//
//  Created by Pierluigi Cifani on 11/04/2017.
//

import BSWInterfaceKit
import XCTest

@available(iOS 11.0, *)
class UIViewControllerTests: BSWSnapshotTest {

    func testAddBottomActionButton() {
        guard UIDevice.current.model != "iPad" else { return }
        let vc = BottomActionVC()
        waitABitAndVerify(viewController: vc)
    }

    func testAddBottomActionButtonWithMargin() {
        guard UIDevice.current.model != "iPad" else { return }
        let vc = BottomActionVC()
        vc.margin = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        waitABitAndVerify(viewController: vc)
    }

    func testErrorView() {
        let vc = TestViewController()
        let buttonConfig = ButtonConfiguration(title: "Retry", titleColor: .blue) {
            
        }
        vc.showErrorMessage("Something Failed", error: "Some Error", retryButton: buttonConfig)
        waitABitAndVerify(viewController: vc)
    }
    
    func testLoadingView() {
        let vc = TestViewController()
        let loadingView: UIView = {
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
        }()
        vc.showLoadingView(loadingView)
        waitABitAndVerify(viewController: vc)
    }
}

@available(iOS 11.0, *)
private class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

@available(iOS 11.0, *)
private class BottomActionVC: UIViewController {
    
    var margin: UIEdgeInsets = .zero
    var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let config = ButtonConfiguration(title: "Send Wink", titleColor: .white, backgroundColor: .red, contentInset: .zero) { }
        button = addBottomActionButton(buttonConfig: config, margin: margin)
    }
}

 extension String: LocalizedError {
}
