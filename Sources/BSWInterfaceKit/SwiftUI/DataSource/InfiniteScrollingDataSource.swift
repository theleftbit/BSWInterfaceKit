#if canImport(SwiftUI)

import SwiftUI

@MainActor
open class InfiniteScrollingDataSource<ListItem: Identifiable>: ObservableObject {
    
    @Published public private(set) var items = [ListItem]()
    @Published public private(set) var state: State
    private var itemFetcher: ItemFetcher
    private let direction: Direction
    
    public enum State: Equatable {
        case noMorePages
        case loading
        case canLoadMorePages(currentPage: Int)
    }
    
    public enum Direction {
        case upwards
        case downwards
    }
    
    public typealias ItemFetcher = (Int) async throws -> ([ListItem], Bool)
    
    public init(currentPage: Int = 0, direction: Direction = .downwards, itemFetcher: @escaping ItemFetcher) async throws {
        self.itemFetcher = itemFetcher
        self.state = State.canLoadMorePages(currentPage: currentPage)
        self.direction = direction
        try await loadMoreContent()
    }
    
    public init(mockItems: [ListItem], direction: Direction = .downwards) {
        self.items = mockItems
        self.state = .noMorePages
        self.direction = direction
        self.itemFetcher = { _ in return ([], false) }
    }
    
    public func insert(_ newItems: [ListItem], position: Int = 0) {
        withAnimation {
            self.items.insert(contentsOf: newItems, at: position)
        }
    }
    
    public func appendItem(_ newItem: ListItem) {
        withAnimation {
            self.items.append(newItem)
        }
    }
    
    public func removeItem(_ item: ListItem) {
        withAnimation {
            self.items.removeAll(where: { $0.id == item.id })
        }
    }
    
    public func loadMoreContentIfNeeded(currentItem item: ListItem) {
        let subArray = (direction == .downwards) ? items.suffix(5) : items.prefix(5)
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
    
    @MainActor
    private func loadMoreContent() async throws {
        guard case .canLoadMorePages(let currentPage) = state else {
            return
        }
        
        withAnimation {
            self.state = .loading
        }
        
        let (newItems, thereAreMorePages) = try await self.itemFetcher(currentPage)
        
        withAnimation {
            self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
            switch direction {
            case .upwards:
                self.items.insert(contentsOf: newItems, at: 0)
            case .downwards:
                self.items.append(contentsOf: newItems)
            }
        }
    }
}

#endif
