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
    
    public enum Direction {
        case ascendent
        case descendent
    }
    
    public typealias ItemFetcher = (Int) async throws -> ([ListItem], Bool)
    
    public init(currentPage: Int = 0, direction: Direction = .descendent, itemFetcher: @escaping ItemFetcher) async throws {
        self.itemFetcher = itemFetcher
        self.state = State.canLoadMorePages(currentPage: currentPage)
        try await loadMoreContent(direction: direction)
    }
    
    public init(mockItems: [ListItem]) {
        self.items = mockItems
        self.state = .noMorePages
        self.itemFetcher = { _ in return ([], false) }
    }
    
    public func loadMoreContentIfNeeded(currentItem item: ListItem, direction: Direction = .descendent) {
        switch direction {
        case .descendent:
            let thresholdIndexDesc = items.index(items.endIndex, offsetBy: -5)
            if items.firstIndex(where: { $0.id == item.id }) == thresholdIndexDesc {
                Task {
                    try await loadMoreContent(direction: .descendent)
                }
            }
        case .ascendent:
            let thresholdIndexAsc = items.index(items.startIndex, offsetBy: 5)
            if items.firstIndex(where: { $0.id == item.id }) == thresholdIndexAsc {
                Task {
                    try await loadMoreContent(direction: .ascendent)
                }
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
    
    private func loadMoreContent(direction: Direction = .descendent) async throws {
        guard case .canLoadMorePages(let currentPage) = state else {
            return
        }

        withAnimation {
            self.state = .loading
        }

        let (newItems, thereAreMorePages) = try await self.itemFetcher(currentPage)
        let duration: Double = 0.2
        let stateAnimation = Animation.easeInOut(duration: duration)
        let itemsAnimation = Animation.easeInOut(duration: duration).delay(duration)

        switch direction {
        case .descendent:
            withAnimation(stateAnimation) {
                self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
            }
            withAnimation(itemsAnimation) {
                self.items.append(contentsOf: newItems)
            }
        case .ascendent:
            withAnimation(stateAnimation) {
                self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
            }
            withAnimation(itemsAnimation) {
                self.items.insert(contentsOf: newItems, at: 0)
            }
        }
    }
}

#endif
