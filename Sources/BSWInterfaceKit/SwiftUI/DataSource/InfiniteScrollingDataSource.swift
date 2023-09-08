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
        let thresholdIndices = [items.index(items.endIndex, offsetBy: -5),
                                items.index(items.endIndex, offsetBy: -4),
                                items.index(items.endIndex, offsetBy: -3),
                                items.index(items.endIndex, offsetBy: -2),
                                items.index(items.endIndex, offsetBy: -1)]
        
        if let itemIndex = items.firstIndex(where: { $0.id == item.id }),
           thresholdIndices.contains(itemIndex) {
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
        let duration: Double = 0.1

        withAnimation(.easeInOut(duration: duration)) {
            self.state = .loading
        }

        let (newItems, thereAreMorePages) = try await self.itemFetcher(currentPage)
        let stateAnimation = Animation.easeInOut(duration: duration)
        let itemsAnimation = Animation.easeInOut(duration: duration)

        withAnimation(stateAnimation) {
            self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
        }
        
        withAnimation(itemsAnimation) {
            self.items.append(contentsOf: newItems)
        }
    }
}

#endif
