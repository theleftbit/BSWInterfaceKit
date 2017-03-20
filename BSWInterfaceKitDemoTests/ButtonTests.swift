//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import FBSnapshotTestCase
@testable import BSWInterfaceKit

class ButtonTests: BSWSnapshotTest {

    open var button: UIButton!

    override func setUp() {
        super.setUp()
        isDeviceAgnostic = false
        recordMode = true
    }

    func testRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        waitABitAndVerify(view: button)
    }

    func testEnabledRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        button.isSelected = true
        waitABitAndVerify(view: button)
    }

    static func buttonForRadioTests() -> UIButton {
        let button = CheckboxButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Push Me", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: button.intrinsicContentSize.width, height: button.intrinsicContentSize.height)
        return button
    }
}
