#if canImport(SwiftUI)

import SwiftUI

public protocol PlaceholderDataProvider {
    associatedtype Data
    static func generatePlaceholderData() -> Data
}

/// A SwiftUI View with an async state.
/// Use it like this:
///
///     var body: some View {
///         AsyncStateView(id: "Da Antonio", dataGenerator: {
///             ["Pasta", "Polpette", "Tiramisù", "Caffè", "Ammazza Caffè"]
///         }, hostedViewGenerator: {
///             RecipeListView(contents: $0)
///         })
///     }
///
/// This view has an associated state depending on the state of the fetch:
///
///     enum AsyncState<T> {
///         case loading
///         case loaded(T)
///         case error(Swift.Error)
///     }
///
/// The generator is an `async throws` function which takes no params and gives a `HostedView.Data` result.
/// It gets called using `.task` on the `.loading` state, so it will fire only when shown.
///
/// `AsyncStateView` also makes use of SwiftUI's `redacted` modifier to show a placeholder view for the data.
/// To do so, implement `generatePlaceholderData()` from `PlaceholderDataProvider` protocol
///
public struct AsyncStateView<Data, HostedView: View, ErrorView: View, LoadingView: View>: View {
    
    /// Represents the state of this view
    enum AsyncState<T> {
        case loading
        case loaded(T)
        case error(Swift.Error)
    }

    public typealias DataGenerator = () async throws -> Data
    public typealias HostedViewGenerator = (Data) -> HostedView
    public typealias ErrorViewGenerator = (Swift.Error, @escaping OnRetryHandler) -> ErrorView
    public typealias LoadingViewGenerator = () -> LoadingView
    public typealias OnRetryHandler = () -> ()
    
    let id: String
    let dataGenerator: DataGenerator
    let hostedViewGenerator: HostedViewGenerator
    let errorViewGenerator: ErrorViewGenerator
    let loadingView: LoadingView
    @State private var state: AsyncState<Data> = .loading
    
    /// Creates a new `AsyncStateView`
    /// - Parameters:
    ///   - id: An identifier for this view. This allows SwiftUI to unequivocally know what's being rendered when the view is loaded.
    ///   For this value you can use the remote ID of the object being loaded.
    ///   - dataGenerator: The function that generates the data that is required for your `HostedView`
    ///   - hostedViewGenerator: The function that creates the `HostedView`.
    ///   - errorViewGenerator: The function that creates the `ErrorView`.
    ///   - loadingViewGenerator: The function that creates the `LoadingView`.
    public init(id: String,
                dataGenerator: @escaping DataGenerator,
                @ViewBuilder hostedViewGenerator: @escaping HostedViewGenerator,
                @ViewBuilder errorViewGenerator: @escaping ErrorViewGenerator,
                @ViewBuilder loadingViewGenerator: LoadingViewGenerator) {
        self.id = id
        self.dataGenerator = dataGenerator
        self.hostedViewGenerator = hostedViewGenerator
        self.errorViewGenerator = errorViewGenerator
        self.loadingView = loadingViewGenerator()
    }
    
    public var body: some View {
        switch state {
        case .loading:
            loadingView
                .task { await fetchData() }
        case .loaded(let data):
            hostedViewGenerator(data)
                .id(id)
        case .error(let error):
            errorViewGenerator(error, {
                self.state = .loading
            })
        }
    }
    
    //MARK: Private
    
    private func fetchData() async {
        do {
            let data = try await dataGenerator()
            withAnimation {
                self.state = .loaded(data)
            }
        } catch {
            withAnimation {
                self.state = .error(error)
            }
        }
    }
}

public extension AsyncStateView where ErrorView == AsyncStatePlainErrorView {
    init(id: String,
         dataGenerator: @escaping DataGenerator,
         hostedViewGenerator: @escaping HostedViewGenerator,
         loadingViewGenerator: @escaping LoadingViewGenerator) {
        self.init(
            id: id,
            dataGenerator: dataGenerator,
            hostedViewGenerator: hostedViewGenerator,
            errorViewGenerator: { AsyncStatePlainErrorView(error: $0, onRetry: $1)},
            loadingViewGenerator: loadingViewGenerator
        )
    }
}

public extension AsyncStateView where HostedView: PlaceholderDataProvider, LoadingView == AsyncStatePlainLoadingView<HostedView>, HostedView.Data == Data {
    init(id: String,
         dataGenerator: @escaping DataGenerator,
         hostedViewGenerator: @escaping HostedViewGenerator,
         errorViewGenerator: @escaping ErrorViewGenerator) {
        let placeholderData = HostedView.generatePlaceholderData()
        let placeholderView = hostedViewGenerator(placeholderData)
        self.init(
            id: id,
            dataGenerator: dataGenerator,
            hostedViewGenerator: hostedViewGenerator,
            errorViewGenerator: errorViewGenerator,
            loadingViewGenerator: { AsyncStatePlainLoadingView(contentView: placeholderView) }
        )
    }
}

public extension AsyncStateView where HostedView: PlaceholderDataProvider, LoadingView == AsyncStatePlainLoadingView<HostedView>, HostedView.Data == Data, ErrorView == AsyncStatePlainErrorView {
    init(id: String,
         dataGenerator: @escaping DataGenerator,
         hostedViewGenerator: @escaping HostedViewGenerator) {
        let placeholderData = HostedView.generatePlaceholderData()
        let placeholderView = hostedViewGenerator(placeholderData)
        self.init(
            id: id,
            dataGenerator: dataGenerator,
            hostedViewGenerator: hostedViewGenerator,
            errorViewGenerator: { AsyncStatePlainErrorView(error: $0, onRetry: $1) },
            loadingViewGenerator: { AsyncStatePlainLoadingView(contentView: placeholderView) }
        )
    }
}

public struct AsyncStatePlainErrorView: View {

    let error: Swift.Error
    let onRetry: () -> ()
    
    public var body: some View {
        VStack(spacing: 16) {
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
            Button("Retry") {
                self.onRetry()
            }
        }
        .padding()
    }
}

public struct AsyncStatePlainLoadingView<T: View>: View {
    
    public init(contentView: T) {
        self.contentView = contentView
    }
    
    let contentView: T
    public var body: some View {
        contentView
            .redacted(reason: .placeholder)
            .disabled(true)
            .shimmering()
    }
}
#endif
