#if canImport(SwiftUI)

import SwiftUI

/// As of iOS 18 and aligned releases, this is no longer recommended as
/// there are cleaner alternatives like `InfiniteVerticalScrollView`
@MainActor
open class InfiniteScrollingDataSource<ListItem: Identifiable & Sendable>: ObservableObject {
    
    @Published public private(set) var items = [ListItem]()
    @Published public private(set) var state: State
    @Published public var paginationError: Error?
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
    
    /// This is a workaround for paging glitches found on iOS 17 and above.
    /// As all workarouds, it's an indicator of a poor design that must be fixed ASAP.
    public func ___update(items: [ListItem]? = nil, state: State? = nil) {
        if let items {
            self.items = items
        }
        if let state {
            self.state = state
        }
    }
    
    /// MARK: Private
    
    @MainActor
    private func loadMoreContent() async throws {
        guard case .canLoadMorePages(let currentPage) = state else {
            return
        }
        
        let previousState = self.state
        withAnimation {
            self.state = .loading
        }
        
        do {
            let (newItems, thereAreMorePages) = try await self.itemFetcher(currentPage)
            
            withAnimation {
                self.state = thereAreMorePages ? .canLoadMorePages(currentPage: currentPage + 1) : .noMorePages
                self.items.append(contentsOf: newItems)
            }
        } catch {
            if error is CancellationError {} else {
                self.paginationError = error
            }
            withAnimation {
                self.state = previousState
            }
        }
    }
}

#endif
