//
//  Created by Michele Restuccia on 25/2/26.
//

import SwiftUI

public extension View {
    
    /// Expands the hit-testing area of a `Button` to the full view on iOS.
    /// Not required on Android, where the default behavior already covers the whole view.
    @ViewBuilder
    func contentRectangleShape() -> some View {
        #if canImport(Darwin)
        self.contentShape(Rectangle())
        #else
        self
        #endif
    }
}
