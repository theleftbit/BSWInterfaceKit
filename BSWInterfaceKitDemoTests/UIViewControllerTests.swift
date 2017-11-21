//
//  Created by Pierluigi Cifani on 11/04/2017.
//

@testable import BSWInterfaceKit
import XCTest

class UIViewControllerTests: BSWSnapshotTest {

    func testAddBottomActionButton() {
        let vc = BottomActionVC()
        waitABitAndVerify(viewController: vc)
    }
}

private class BottomActionVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let config = ButtonConfiguration(title: "Send Wink", titleColor: .white, backgroundColor: .red, contentInset: .zero) { }
        addBottomActionButton(config)
    }
}
