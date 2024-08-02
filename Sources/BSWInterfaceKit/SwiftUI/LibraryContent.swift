
import SwiftUI

struct BSWInterfaceKit_SwiftUILibrary: LibraryContentProvider {
    
    public var views: [LibraryItem] {
        return MainActor.assumeIsolated {
            [
                LibraryItem(PhotoView(photo: .emptyPhoto()), title: "Photo View", category: .other, matchingSignature: "photovie"),
                LibraryItem(AsyncButton("", action: {}), title: "Async Button", category: .control, matchingSignature: "asyncbutton")
            ]
        }
    }
}

#if swift(>=6.0)
extension LibraryItem: @unchecked @retroactive Sendable {}
#else
extension LibraryItem: @unchecked Sendable {}
#endif
