//
//  Created by Michele Restuccia on 22/2/23.
//

#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class CheckboxButtonTests: BSWSnapshotTest {

    @MainActor
    func testCheckboxButton() {
        let button = CheckboxButton()
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
    
    @MainActor
    func testCheckboxButtonSelected() {
        let button = CheckboxButton()
        button.isSelected = true
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
}

#endif
