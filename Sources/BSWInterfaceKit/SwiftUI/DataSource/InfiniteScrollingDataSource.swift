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
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
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
    
    @MainActor
    private func loadMoreContent() async throws {
        guard case .canLoadMorePages(let currentPage) = state else {
            return
        }
        withAnimation {
            self.state = .loading
        }
        let (items, thereAreMorePages) = try await self.itemFetcher(currentPage)
        let duration: Double = 0.2
        let stateAnimation = Animation.easeInOut(duration: duration)
        let itemsAnimation = Animation.easeInOut(duration: duration).delay(duration)
        withAnimation(stateAnimation) {
            self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
        }
        withAnimation(itemsAnimation) {
            self.items.append(contentsOf: items)
        }
    }
}

#endif
