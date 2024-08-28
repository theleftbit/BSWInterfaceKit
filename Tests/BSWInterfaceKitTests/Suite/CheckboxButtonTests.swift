//
//  Created by Michele Restuccia on 22/2/23.
//

#if canImport(UIKit)
#if canImport(Testing)

import BSWInterfaceKit
import Testing
import UIKit

class CheckboxButtonTests: BSWSnapshotTest {

    @Test
    func checkboxButton() {
        let button = CheckboxButton()
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
    
    @Test
    func checkboxButtonSelected() {
        let button = CheckboxButton()
        button.isSelected = true
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
}

#endif
#endif
