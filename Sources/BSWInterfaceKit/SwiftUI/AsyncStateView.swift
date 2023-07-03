#if canImport(SwiftUI)

import SwiftUI

#if compiler(>=5.9)
struct RecipeListView: View, PlaceholderDataProvider {
    
    let recipes: [String]
    var body: some View {
        Form {
            ForEach(recipes, id: \.self) {
                Text($0)
            }
        }
    }
    
    static func generatePlaceholderData() -> [String] {
        ["Pasta", "Polpette", "Tiramisù", "Caffè", "Ammazza Caffè"]
    }
}
#Preview {
    if #available(iOS 16, *) {
        AsyncStateView(id: "some-id", dataGenerator: {
            try await Task.sleep(for: .seconds(1))
            return ["Pasta", "Polpette", "Tiramisù", "Caffè", "Ammazza Caffè"]
        }, hostedViewGenerator: {
            RecipeListView(recipes: $0)
        })
    } else {
        EmptyView()
    }
}
#endif

/// A SwiftUI View with an async state.
///
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
/// The generator is an `async throws` function which takes no params and returns a `HostedView.Data`.
/// It gets called using `.task` on the `.loading` state, so it will fire only when shown.
///
/// `AsyncStateView` also makes use of SwiftUI's `redacted` modifier to show a placeholder view for the data.
/// To do so, implement `generatePlaceholderData()` from `PlaceholderDataProvider` protocol
///
public struct AsyncStateView<Data, HostedView: View, ErrorView: View, LoadingView: View>: View {
    
    /// Represents the state of this view
    enum AsyncState {
        case loading
        case loaded(Data)
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
    @State private var state: AsyncState = .loading
    
    /// Creates a new `AsyncStateView`
    /// - Parameters:
    ///   - id: The identifier for this view. This allows SwiftUI to unequivocally know what's being rendered when the view is loaded. For this value you can use the remote ID of the object being loaded.
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
        Group {
            switch state {
            case .loading:
                loadingView
            case .loaded(let data):
                hostedViewGenerator(data)
            case .error(let error):
                errorViewGenerator(error, {
                    fetchData()
                })
            }
        }
        /// Whenever the ID changes, start a new fetch operation
        .task(id: id) {
            await fetchData()
        }
        /// If when we appear the state is an error because
        /// of a cancellation, we should retry the operation
        .onAppear {
            guard state.isCancelledError else { return }
            fetchData()
        }
    }
    
    //MARK: Private

    @Environment(\.redactionReasons) private var reasons

    private func fetchData() {
        Task { await fetchData() }
    }

    @MainActor
    private func fetchData() async {
        if reasons.contains(.placeholder) {
            /// Make sure no request is fired in case that this view
            /// is used to compose a sub-section of the view hierarchy.
            return
        }
        withAnimation {
            self.state = .loading
        }
        do {
            let finalData = try await dataGenerator()
            withAnimation {
                self.state = .loaded(finalData)
            }
        } catch is CancellationError {
            /// Do nothing as we handle this `.onAppear`
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

extension AsyncStateView.AsyncState {
    var isCancelledError: Bool {
        switch self {
        case .error(let error):
            return error.isURLCancelled || error is CancellationError
        default:
            return false
        }
    }
}

#endif
