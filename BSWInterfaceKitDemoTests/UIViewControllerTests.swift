//
//  Created by Pierluigi Cifani on 11/04/2017.
//

import BSWInterfaceKit
import XCTest

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
}
