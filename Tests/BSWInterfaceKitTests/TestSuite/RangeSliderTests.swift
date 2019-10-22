//
//  Created by Michele Restuccia on 22/10/2019.
//

import BSWInterfaceKit
import XCTest
import SnapshotTesting

class RangeSliderTests: BSWSnapshotTest {
    var sut: RangeSlider!
    override func setUp() {
        super.setUp()
        sut = RangeSlider()
        sut.configureFor(viewModel: .init(values: (10, 60), trackTintColor: .gray, trackHighlightTintColor: .red, thumbTintColor: .white))
        sut.frame = CGRect(x: 0, y: 0, width: 350, height: 32)
    }
    
    func testLayout() {
        verify(view: sut)
    }
}
