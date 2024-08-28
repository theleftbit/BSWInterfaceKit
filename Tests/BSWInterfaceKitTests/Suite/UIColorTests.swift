#if canImport(UIKit)
#if canImport(Testing)

import BSWInterfaceKit
import BSWFoundation
import Testing
import UIKit

struct UIColorTests {
    
    @Test
    func invertColors() {
        let testColor = UIColor.systemBackground
        let lightVariation = testColor.resolvedColor(with: .init(userInterfaceStyle: .light))
        let darkVariation = testColor.invertedForUserInterfaceStyle()
        #expect(lightVariation != darkVariation)
    }
}

#endif
#endif
