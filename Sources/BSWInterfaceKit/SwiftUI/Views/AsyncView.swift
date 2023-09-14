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
        AsyncView(id: "some-id", dataGenerator: {
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
///         AsyncView(id: "Da Antonio", dataGenerator: {
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
/// `AsyncView` also makes use of SwiftUI's `redacted` modifier to show a placeholder view for the data.
/// To do so, implement `generatePlaceholderData()` from `PlaceholderDataProvider` protocol
///
public struct AsyncView<Data, HostedView: View, ErrorView: View, LoadingView: View, ID: Equatable>: View {
    
    /// Represents the state of this view
    struct Operation {
        
        var id: ID
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
    
    @Binding var id: ID
    let dataGenerator: DataGenerator
    let hostedViewGenerator: HostedViewGenerator
    let errorViewGenerator: ErrorViewGenerator
    let loadingView: LoadingView
    @State private var currentOperation: Operation
    
    /// Creates a new `AsyncStateView`
    /// - Parameters:
    ///   - id: A `Binding` to the identifier for this view. This allows SwiftUI to unequivocally know what's being rendered when the view is loaded. For this value you can use the remote ID of the object being loaded.
    ///   - dataGenerator: The function that generates the data that is required for your `HostedView`
    ///   - hostedViewGenerator: The function that creates the `HostedView`.
    ///   - errorViewGenerator: The function that creates the `ErrorView`.
    ///   - loadingViewGenerator: The function that creates the `LoadingView`.
    public init(id: Binding<ID>,
                dataGenerator: @escaping DataGenerator,
                @ViewBuilder hostedViewGenerator: @escaping HostedViewGenerator,
                @ViewBuilder errorViewGenerator: @escaping ErrorViewGenerator,
                @ViewBuilder loadingViewGenerator: LoadingViewGenerator) {
        self._id = id
        self._currentOperation = .init(initialValue: .init(id: id.wrappedValue, phase: .idle))
        self.dataGenerator = dataGenerator
        self.hostedViewGenerator = hostedViewGenerator
        self.errorViewGenerator = errorViewGenerator
        self.loadingView = loadingViewGenerator()
    }

    public init(id: ID,
                dataGenerator: @escaping DataGenerator,
                @ViewBuilder hostedViewGenerator: @escaping HostedViewGenerator,
                @ViewBuilder errorViewGenerator: @escaping ErrorViewGenerator,
                @ViewBuilder loadingViewGenerator: LoadingViewGenerator) {
        self.init(id: .constant(id), dataGenerator: dataGenerator, hostedViewGenerator: hostedViewGenerator, errorViewGenerator: errorViewGenerator, loadingViewGenerator: loadingViewGenerator)
    }

    public var body: some View {
        /// Using `VStack` here seems to be safer than `Group`
        /// in terms of maintaining Structural Identity.
        VStack {
            switch currentOperation.phase {
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
    @Environment(\.debounceOperationForMilliseconds) var debounceOperationForMilliseconds

    private func fetchData() {
        Task { await fetchData() }
    }

    @MainActor
    private func fetchData() async {
        /// Make sure no request is fired in case that this view
        /// is used to compose a sub-section of the view hierarchy.
        if reasons.contains(.placeholder) { return }
        
        /// Turns out `.task { }` is called also
        /// when the view appears so if we're already
        /// loaded do not schedule a new fetch operation.
        if currentOperation.isLoaded(forID: id) { return }
        
        /// If the previous fetch has failed for non-cancelling reasons,
        /// then we should not retry the operation automatically
        /// and give the user chance to retry it using the UI.
        if currentOperation.isNonCancelledError(forID: id) { return }
        
        /// In case the environment tells us to debounce the operation, lets.
        if let debounceOperationForMilliseconds {
            let uint64 = UInt64(debounceOperationForMilliseconds)
            try? await Task.sleep(nanoseconds: uint64 * 1_000_000)
        }

        /// If we we are on the right state, let's perform the fetch.
        currentOperation.id = id
        withAnimation {
            currentOperation.phase = .loading
        }
        do {
            let finalData = try await dataGenerator()
            withAnimation {
                currentOperation.phase = .loaded(finalData)
            }
        } catch is CancellationError {
            /// Do nothing as we handle this `.task`
        } catch let error where error.isURLCancelled {
            /// Do nothing as we handle this `.task`
        } catch {
            withAnimation {
                currentOperation.phase = .error(error)
            }
        }
    }
}

public extension AsyncView where ErrorView == AsyncStatePlainErrorView {
    init(id: Binding<ID>,
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

    init(id: ID,
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

public extension AsyncView where HostedView: PlaceholderDataProvider, LoadingView == AsyncStatePlainLoadingView<HostedView>, HostedView.Data == Data {
    init(id: Binding<ID>,
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

    init(id: ID,
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

public extension AsyncView where HostedView: PlaceholderDataProvider, LoadingView == AsyncStatePlainLoadingView<HostedView>, HostedView.Data == Data, ErrorView == AsyncStatePlainErrorView {
    init(id: Binding<ID>,
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
    
    init(id: ID,
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

public extension View {
    func asyncViewDebounceOperation(milliseconds: Double) -> some View {
        self.environment(\.debounceOperationForMilliseconds, milliseconds)
    }
}

private struct DebounceOperationForMilliseconds: EnvironmentKey {
    static let defaultValue: Double? = nil
}

private extension EnvironmentValues {
    var debounceOperationForMilliseconds: Double? {
        get { self[DebounceOperationForMilliseconds.self] }
        set { self[DebounceOperationForMilliseconds.self] = newValue }
    }
}

private extension AsyncView.Operation {
    
    func isNonCancelledError(forID id: ID) -> Bool {
        guard self.id == id else { return false }
        switch self.phase {
        case .error(let error):
            let isCancelledError = (error.isURLCancelled || error is CancellationError)
            return !isCancelledError
        default:
            return false
        }
    }

    func isLoaded(forID id: ID) -> Bool {
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
