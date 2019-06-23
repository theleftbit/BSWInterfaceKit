import SwiftUI
import Combine

@available(iOS 13.0, *)
public protocol ViewModelInitiable {
    associatedtype VM
    init(vm: VM)
}

@available(iOS 13.0, *)
public struct AsyncView<HostedView: View & ViewModelInitiable>: View {
    
    public init(dataFetcher: Publishers.Future<HostedView.VM, Error>) {
        self.dataFetcher = dataFetcher
    }
    
    private let dataFetcher: Publishers.Future<HostedView.VM, Error>
    @State private var asyncState = AsyncState.loading
    
    private enum AsyncState {
        case loading
        case failed(Error)
        case loaded(HostedView.VM)
    }
    
    public var body: some View {
        generateView()
            .onAppear {
                self.fetchData()
        }
    }
    
    private func fetchData() {
        var cancellable: Cancellable!
        cancellable = dataFetcher.sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                self.asyncState = .failed(error)
            default:
                break
            }
            cancellable = nil
        }, receiveValue: {
            self.asyncState = .loaded($0)
        })
    }
    
    private func generateView() -> some View {
        switch asyncState {
        case .loading:
            return AnyView(Loading(loadingMessage: TextStyler.styler.attributedString("Loading...")))
        case .failed(let error):
            return AnyView(Text("Error: \(error.localizedDescription)"))
        case .loaded(let vms):
            return AnyView(HostedView(vm: vms))
        }
    }
}
