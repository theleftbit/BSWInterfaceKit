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
/// This view represents the phase of the fetch with the following type:
///
///     enum Operation.Phase {
///         case idle
///         case loading
///         case loaded(Data)
///         case error(Swift.Error)
///     }
///
/// The `dataGenerator` parameter is an `async throws` function which takes no params and
/// returns a `HostedView.Data`.  It gets called using `.task` on the `.loading` phase, so it
/// will fire only when shown or `id` changes.
///
/// `AsyncStateView` also makes use of SwiftUI's `redacted` modifier to show a placeholder view for the data.
/// To do so, implement `generatePlaceholderData()` from `PlaceholderDataProvider` protocol
///
public struct AsyncStateView<Data, HostedView: View, ErrorView: View, LoadingView: View>: View {
    
    /// Represents the state of this view
    struct Operation {
        
        var id: String
        var phase: Phase
        
        enum Phase {
            case idle
            case loading
            case loaded(Data)
            case error(Swift.Error)
        }
    }
    
    public typealias DataGenerator = () async throws -> Data
    public typealias HostedViewGenerator = (Data) -> HostedView
    public typealias ErrorViewGenerator = (Swift.Error, @escaping OnRetryHandler) -> ErrorView
    public typealias LoadingViewGenerator = () -> LoadingView
    public typealias OnRetryHandler = () -> ()
    
    @Binding var id: String
    let dataGenerator: DataGenerator
    let hostedViewGenerator: HostedViewGenerator
    let errorViewGenerator: ErrorViewGenerator
    let loadingView: LoadingView
    @State private var operation: Operation
    
    /// Creates a new `AsyncStateView`
    /// - Parameters:
    ///   - id: A `Binding` to the identifier for this view. This allows SwiftUI to unequivocally know what's being rendered when the view is loaded. For this value you can use the remote ID of the object being loaded.
    ///   - dataGenerator: The function that generates the data that is required for your `HostedView`
    ///   - hostedViewGenerator: The function that creates the `HostedView`.
    ///   - errorViewGenerator: The function that creates the `ErrorView`.
    ///   - loadingViewGenerator: The function that creates the `LoadingView`.
    public init(id: Binding<String>,
                dataGenerator: @escaping DataGenerator,
                @ViewBuilder hostedViewGenerator: @escaping HostedViewGenerator,
                @ViewBuilder errorViewGenerator: @escaping ErrorViewGenerator,
                @ViewBuilder loadingViewGenerator: LoadingViewGenerator) {
        self._id = id
        self._operation = .init(initialValue: .init(id: id.wrappedValue, phase: .idle))
        self.dataGenerator = dataGenerator
        self.hostedViewGenerator = hostedViewGenerator
        self.errorViewGenerator = errorViewGenerator
        self.loadingView = loadingViewGenerator()
    }

    public init(id: String,
                dataGenerator: @escaping DataGenerator,
                @ViewBuilder hostedViewGenerator: @escaping HostedViewGenerator,
                @ViewBuilder errorViewGenerator: @escaping ErrorViewGenerator,
                @ViewBuilder loadingViewGenerator: LoadingViewGenerator) {
        self.init(id: .constant(id), dataGenerator: dataGenerator, hostedViewGenerator: hostedViewGenerator, errorViewGenerator: errorViewGenerator, loadingViewGenerator: loadingViewGenerator)
    }

    public var body: some View {
        Group {
            switch operation.phase {
            case .idle, .loading:
                loadingView
            case .loaded(let data):
                hostedViewGenerator(data)
            case .error(let error):
                errorViewGenerator(error, {
                    fetchData()
                })
            }
        }
        .task(id: id) {
            await fetchData()
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
        /// Turns out `.task { }` is called also
        /// when the view appears so if we're already
        /// loaded do not schedule a new fetch operation.
        if operation.isLoaded(forID: id) { return }
        
        /// If the previous fetch has failed for non-cancelling reasons,
        /// then we should not retry the operation automatically
        /// and give the user chance to retry it using the UI.
        if operation.isNonCancelledError(forID: id) { return }
        
        /// If we we are on the right state, let's perform the fetch.
        operation.id = id
        withAnimation {
            operation.phase = .loading
        }
        do {
            let finalData = try await dataGenerator()
            withAnimation {
                operation.phase = .loaded(finalData)
            }
        } catch is CancellationError {
            /// Do nothing as we handle this `.onAppear`
        } catch {
            withAnimation {
                operation.phase = .error(error)
            }
        }
    }
}

public extension AsyncStateView where ErrorView == AsyncStatePlainErrorView {
    init(id: Binding<String>,
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
    init(id: Binding<String>,
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
    init(id: Binding<String>,
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

private extension AsyncStateView.Operation {
    
    func isNonCancelledError(forID id: String) -> Bool {
        guard self.id == id else { return false }
        switch self.phase {
        case .error(let error):
            let isCancelledError = (error.isURLCancelled || error is CancellationError)
            return !isCancelledError
        default:
            return false
        }
    }

    func isLoaded(forID id: String) -> Bool {
        guard self.id == id else { return false }
        switch self.phase {
        case .loaded:
            return true
        default:
            return false
        }
    }
}

#endif
