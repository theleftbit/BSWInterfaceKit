
import SwiftUI

struct BSWInterfaceKit_SwiftUILibrary: LibraryContentProvider {
    public var views: [LibraryItem] {
        return [
            LibraryItem(PhotoView(photo: .emptyPhoto()), title: "Photo View", category: .other, matchingSignature: "photovie"),
            LibraryItem(AsyncButton("", action: {}), title: "Async Button", category: .control, matchingSignature: "asyncbutton")
        ]
    }
}
