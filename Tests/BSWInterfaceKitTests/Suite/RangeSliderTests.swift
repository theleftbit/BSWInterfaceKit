//
//  Created by Michele Restuccia on 22/10/2019.
//

import BSWInterfaceKit
import Testing
import UIKit

class RangeSliderTests: BSWSnapshotTest {
    
    @Test
    func layout() {
        var range = Range<Double>(uncheckedBounds: (10, 60))
        let sut = RangeSlider(configuration: .init(range: range, trackTintColor: .gray, trackHighlightTintColor: .red, thumbTintColor: .white))
        sut.frame = CGRect(x: 0, y: 0, width: 350, height: 32)

        range = Range<Double>(uncheckedBounds: (12, 55))
        sut.configureFor(viewModel: .init(selectedRange: range))
        verify(view: sut)
        #expect(sut.selectedRange == range)
    }
}
