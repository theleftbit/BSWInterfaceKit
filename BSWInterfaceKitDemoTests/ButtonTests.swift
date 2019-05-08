//
//  Created by Pierluigi Cifani on 20/03/2017.
//

import XCTest
import BSWInterfaceKit

class ButtonTests: BSWSnapshotTest {

    open var button: UIButton!

    func testRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        verify(view: button)
    }

    func testEnabledRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        button.isSelected = true
        verify(view: button)
    }

    func testImageButton() {
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: .image(#imageLiteral(resourceName: "women")), actionHandler: {}))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }

    func testImageButtonWithCornerRadius() {
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: .image(#imageLiteral(resourceName: "women")), cornerRadius: 5, actionHandler: {}))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }

    func testImageTitleButton() {
        let image: UIImage = #imageLiteral(resourceName: "women")
        let title = NSAttributedString(string: "Click Me")
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: ButtonTitle.textAndImage(title, image), actionHandler: {}))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
    
    func testTapButton() {
        
        let exp = expectation(description: "Expecting touches in button")
        
        var isActionHandled: Bool = false
        
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: .image(#imageLiteral(resourceName: "women")), actionHandler: {
            isActionHandled = true
            exp.fulfill()
        }))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        
        button.sendActions(for: .touchUpInside)
        
        let _ = XCTWaiter().wait(for: [exp], timeout: 1)
        
        XCTAssert(isActionHandled)
    }

    // MARK: Private

    fileprivate static func buttonForRadioTests() -> UIButton {
        let button = CheckboxButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Push Me", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: button.intrinsicContentSize.width, height: button.intrinsicContentSize.height)
        return button
    }
}
