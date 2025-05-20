#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

/// A protocol that defines types that return placeholder data to be used for Previews or loading states.
public protocol PlaceholderDataProvider: View {
    associatedtype PlaceholderData
    
    static func generatePlaceholderData() -> PlaceholderData
}
