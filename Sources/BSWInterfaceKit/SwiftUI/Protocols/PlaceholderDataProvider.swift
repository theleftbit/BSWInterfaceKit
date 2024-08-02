
/// A protocol that defines types that return placeholder data to be used for Previews or loading states.
public protocol PlaceholderDataProvider {
    associatedtype Data
    
    @MainActor
    static func generatePlaceholderData() -> Data
}
