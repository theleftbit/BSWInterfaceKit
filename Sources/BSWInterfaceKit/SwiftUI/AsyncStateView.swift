
#if canImport(SwiftUI)

import SwiftUI

@available(iOS 14, *)
public protocol ViewDataInitiable {
    associatedtype Data
    init(data: Data)
}

/*
 Use this view like this:
```
 AsyncStateView<ProductDetailsView>(
     model: AsyncStateModel(
         generator: Current.productDetailFactory(productID)
     )
 )
 ```
 */

@available(iOS 14, *)
public struct AsyncStateView<HostedView: View & ViewDataInitiable>: View {
    
    @StateObject public var model: AsyncStateModel<HostedView.Data>

    public var body: some View {
        switch model.state {
        case .loading:
            ProgressView()
        case .loaded(let data):
            HostedView(data: data)
        case .error(let error):
            ErrorView(error: error, onRetry: {
                self.model.fetchData()
            })
        }
    }
}

import Combine

@available(iOS 14, *)
private extension AsyncStateView {
    struct ErrorView: View {
        let error: Swift.Error
        let onRetry: () -> ()
        
        var body: some View {
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
}


@available(iOS 14, *)
public class AsyncStateModel<T>: ObservableObject {

    public typealias Generator = () -> Combine.AnyPublisher<T, Swift.Error>

    @Published public var state: State<T>
    public let generator: Generator
    
    public init(generator: @escaping Generator) {
        self.generator = generator
        self.state = .loading
        fetchData()
    }

    init(state: State<T>) {
        self.state = state
        self.generator = { Future.never().eraseToAnyPublisher() }
        fetchData()
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    private var cancellable: AnyCancellable!
    
    func fetchData() {
        self.state = .loading
        let fetch = self.generator()
        cancellable = fetch.receive(on: DispatchQueue.main).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                self.state = .error(error)
            case .finished:
                break
            }
            self.cancellable.cancel()
            self.cancellable = nil
        }, receiveValue: {
            self.state = .loaded($0)
        })
    }

    public enum State<T> {
        case loading
        case loaded(T)
        case error(Swift.Error)
    }
}

@available(iOS 14, *)
private extension Future {
    static func never() -> Future<Output, Failure> {
        return .init { (_) in }
    }
}

#endif
