//
//  Created by Michele Restuccia on 25/2/26.
//

import SwiftUI

public extension View {
    
    @ViewBuilder
    func contentRectangleShape() -> some View {
        #if canImport(Darwin)
        self.contentShape(Rectangle())
        #else
        self
        #endif
    }
}
