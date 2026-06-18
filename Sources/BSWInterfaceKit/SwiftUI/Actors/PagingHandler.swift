//
//  Created by Michele Restuccia on 27/6/25.
//

import SwiftUI

#if canImport(Darwin)

#Preview {
    
    @Previewable
    @State
    var viewModel = PagingHandlerPreviewViewModel()
    
    List {
        ForEach(viewModel.items) { item in
            Text(item.name)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 96,
                    alignment: .leading
                )
        }
        if viewModel.state != .noMorePages {
            ProgressView()
                .frame(maxWidth: .infinity)
                .task { await viewModel.syncData() }
        }
    }
}

@MainActor
@Observable
private class PagingHandlerPreviewViewModel {
    
    struct Item: Identifiable, Sendable {
        let id: Int
        let name: String
    }
    
    var items: [Item] = []
    var state: PagingHandler<Item>.State = .loading
    
    private let pagingHandler: PagingHandler<Item>
    
    init() {
        self.pagingHandler = PagingHandler(initialPage: 1) { pageNumber in
            try await Task.sleep(for: .milliseconds(500))
            
            let items = (1...10).map {
                Item(
                    id: ((pageNumber - 1) * 10) + $0,
                    name: "Item \(((pageNumber - 1) * 10) + $0)"
                )
            }
            return .init(
                items: items,
                totalCount: 30,
                morePagesAreAvailable: pageNumber < 3
            )
        }
    }
    
    func syncData() async {
        do {
            try await pagingHandler.loadMoreContent()
            items = await pagingHandler.getItems()
            state = await pagingHandler.getState()
        } catch {
            state = await pagingHandler.getState()
        }
    }
}

#endif

/**
 A generic, stateful actor that manages paginated fetching of items.
 You provide a closure that fetches a page of data given a zero-based page index, and the actor maintains:
 - its current `state`,
 - the accumulated `items`.
 Use `loadMoreContent()` to fetch the next page,
 and `getState()`/`getItems()` to read the results from outside the actor.
 */
// SKIP @nobridge
public actor PagingHandler<Item: Sendable> {
    
    public enum State: Equatable, Sendable {
        case loading
        case noMorePages
        case canLoadMore(nextPage: Int)
    }
    var state: State
    public func getState() -> State {
        state
    }
    
    private var items: [Item] = []
    public func getItems() -> [Item] {
        items
    }
    
    private var totalCount: Int = 0
    public func getTotalCount() -> Int {
        totalCount
    }
    
    public struct FetchResult: Sendable {
        public let items: [Item]
        public let totalCount: Int
        public let morePagesAreAvailable: Bool
        
        public init(items: [Item], totalCount: Int, morePagesAreAvailable: Bool) {
            self.items = items
            self.totalCount = totalCount
            self.morePagesAreAvailable = morePagesAreAvailable
        }
        fileprivate static var empty: FetchResult {
            .init(items: [], totalCount: 0, morePagesAreAvailable: false)
        }
    }
    public typealias FetchTask = @Sendable (Int) async throws -> FetchResult
    private let fetchPage: FetchTask
    
    public init(
        initialPage: Int = 0,
        fetchPage: @escaping FetchTask
    ) {
        self.state = .canLoadMore(nextPage: initialPage)
        self.fetchPage = fetchPage
    }
    
    public func loadMoreContent() async throws {
        guard case let .canLoadMore(currentPage) = state else { return }
        let previousState = self.state
        state = .loading
        
        do {
            let results = try await fetchPage(currentPage)
            items.append(contentsOf: results.items)
            totalCount = results.totalCount
            
            if results.items.isEmpty || !results.morePagesAreAvailable {
                state = .noMorePages
            } else {
                state = .canLoadMore(nextPage: currentPage + 1)
            }
        } catch is CancellationError {
            state = previousState
        } catch {
            state = previousState
            throw error
        }
    }
    
    /// - Returns: A pre-filled mock instance of `PagingHandler`. (Not for production)
    public static func mock() -> PagingHandler {
        let handler = PagingHandler(initialPage: 0, fetchPage: { _ in .empty })
        Task { await handler.setNoMorePages() }
        return handler
    }
    
    private func setNoMorePages() {
        self.state = .noMorePages
    }
}
