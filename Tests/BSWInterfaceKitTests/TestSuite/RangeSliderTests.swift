//
//  Created by Michele Restuccia on 22/10/2019.
//
#if canImport(UIKit)

import BSWInterfaceKit
import XCTest
import SnapshotTesting

class RangeSliderTests: BSWSnapshotTest {
    var sut: RangeSlider!
    
    override func setUp() {
        super.setUp()
        sut = RangeSlider.init(configuration: .init(trackTintColor: .gray, trackHighlightTintColor: .red, thumbTintColor: .white))
        sut.configureFor(viewModel: .init(minimumValue: 10, maximumValue: 60))
        sut.frame = CGRect(x: 0, y: 0, width: 350, height: 32)
    }
    
    func testLayout() {
        verify(view: sut)
    }
}

#endif
