#if canImport(UIKit)

import XCTest
import BSWInterfaceKit

class CheckboxButtonTests: BSWSnapshotTest {
    
    func testRadioButton() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(attributedText:
            TextStyler.styler.attributedString(
                "You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life")
        )
        verify(view: button, vm: vm)
    }
    
    func testRadioButton_Selected() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(
            attributedText: TextStyler.styler.attributedString("You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life"),
            isSelected: true,
            tintColor: .red
        )
        verify(view: button, vm: vm)
    }
}

#endif
