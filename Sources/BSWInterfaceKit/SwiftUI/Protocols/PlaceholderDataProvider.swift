import SwiftUI

/// A protocol that defines types that return placeholder data to be used for Previews or loading states.
public protocol PlaceholderDataProvider: SwiftUI.View {
    associatedtype PlaceholderData
    
    static func generatePlaceholderData() -> PlaceholderData
}
