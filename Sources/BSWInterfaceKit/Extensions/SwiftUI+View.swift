
#if canImport(UIKit)

import SwiftUI

public extension SwiftUI.View {
     func asViewController() -> UIViewController {
         return UIHostingController(rootView: self)
     }
 }

#endif
