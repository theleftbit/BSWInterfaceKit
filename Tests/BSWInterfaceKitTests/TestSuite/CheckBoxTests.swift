#if canImport(UIKit)

import XCTest
import BSWInterfaceKit

class CheckboxButtonTests: BSWSnapshotTest {
    
    func testCheckboxButton() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(attributedText:
            TextStyler.styler.attributedString(
                "You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life")
        )
        verify(view: button, vm: vm)
    }
    
    func testCheckboxButton_Selected() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(
            attributedText: TextStyler.styler.attributedString("You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life"
            ),
            isSelected: true,
            tintColor: .red
        )
        verify(view: button, vm: vm)
    }
    
    func testCheckboxButton_WithBackground() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(
            attributedText: TextStyler.styler.attributedString(
                "You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life"
            ),
            backgroundColor: .darkGray
        )
        verify(view: button, vm: vm)
    }
    
    func testCheckboxButton_WithBackground_Selected() {
        let button = CheckboxButton()
        let vm = CheckboxButton.VM(
            attributedText: TextStyler.styler.attributedString(
                "You're telling the enemy exactly what you're going to do. No wonder you've been fighting Lorem Ipsum your entire adult life"
            ),
            isSelected: true,
            tintColor: .red,
            backgroundColor: .darkGray
        )
        verify(view: button, vm: vm)
    }
}

#endif
