//
//  Created by Pierluigi Cifani on 11/04/2017.
//

import BSWInterfaceKit
import XCTest

class UIViewControllerTests: BSWSnapshotTest {

    func testAddBottomActionButton() {
        let vc = BottomActionVC()
        waitABitAndVerify(viewController: vc)
    }

    func testAddBottomActionButtonWithMargin() {
        let vc = BottomActionVC()
        vc.margin = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        waitABitAndVerify(viewController: vc)
    }
}

private class BottomActionVC: UIViewController {
    
    var margin: UIEdgeInsets = .zero
    var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let config = ButtonConfiguration(title: "Send Wink", titleColor: .white, backgroundColor: .red, contentInset: .zero) { }
        button = addBottomActionButton(buttonConfig: config, margin: margin)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *), let button = self.button {
            print(button.safeAreaInsets)
            print(button.intrinsicContentSize)

        }
        
    }
}
