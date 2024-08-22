//
//  Created by Michele Restuccia on 22/10/2019.
//
#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class RangeSliderTests: BSWSnapshotTest {
    var sut: RangeSlider!
    
    override func setUp() async throws {
        try await super.setUp()
        let range = Range<Double>(uncheckedBounds: (10, 60))
        sut = RangeSlider(configuration: .init(range: range, trackTintColor: .gray, trackHighlightTintColor: .red, thumbTintColor: .white))
        sut.frame = CGRect(x: 0, y: 0, width: 350, height: 32)
    }
    
    @MainActor
    func testLayout() {
        let range = Range<Double>(uncheckedBounds: (12, 55))
        sut.configureFor(viewModel: .init(selectedRange: range))
        verify(view: sut)
        XCTAssert(sut.selectedRange == range)
        
    }
}

#endif
