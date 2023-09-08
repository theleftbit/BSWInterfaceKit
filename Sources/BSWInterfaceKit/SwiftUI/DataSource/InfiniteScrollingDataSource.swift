#if canImport(SwiftUI)

import SwiftUI

@MainActor
open class InfiniteScrollingDataSource<ListItem: Identifiable>: ObservableObject {
    
    @Published public private(set) var items = [ListItem]()
    @Published public private(set) var state: State
    private var itemFetcher: ItemFetcher
    
    public enum State: Equatable {
        case noMorePages
        case loading
        case canLoadMorePages(currentPage: Int)
    }
    
    public typealias ItemFetcher = (Int) async throws -> ([ListItem], Bool)
    
    public init(currentPage: Int = 0, itemFetcher: @escaping ItemFetcher) async throws {
        self.itemFetcher = itemFetcher
        self.state = State.canLoadMorePages(currentPage: currentPage)
        try await loadMoreContent()
    }
    
    public init(mockItems: [ListItem]) {
        self.items = mockItems
        self.state = .noMorePages
        self.itemFetcher = { _ in return ([], false) }
    }
    
    public func loadMoreContentIfNeeded(currentItem item: ListItem) {
        let subArray = items.suffix(5)
        if subArray.contains(where: { $0.id == item.id }) {
            Task {
                try await loadMoreContent()
            }
        }
    }
    
    public func resetItemFecher(currentPage: Int, itemFetcher: @escaping ItemFetcher) async throws {
        self.items = []
        self.itemFetcher = itemFetcher
        self.state = State.canLoadMorePages(currentPage: currentPage)
        try await loadMoreContent()
    }
    
    /// MARK: Private
    
    public func loadMoreContent() async throws {
        guard case .canLoadMorePages(let currentPage) = state else {
            return
        }
        let stateAnimation = Animation.easeInOut(duration: 0.3)
        
        withAnimation(stateAnimation) {
            self.state = .loading
        }

        let (newItems, thereAreMorePages) = try await self.itemFetcher(currentPage)

        withAnimation(stateAnimation) {
            self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
            self.items.append(contentsOf: newItems)
        }
    }
}

#endif
