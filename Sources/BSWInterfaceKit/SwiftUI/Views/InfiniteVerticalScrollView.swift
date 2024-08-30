#if canImport(UIKit)
/// Example of how to use `InfiniteScrollingDataSource`
/// Note: as of Xcode 14.3.1 this code is not transitioning to .loaded
/// but if you copy/paste the code in an app, it'll work correctly
import SwiftUI

@available(iOS 17, *)
#Preview {
    NavigationStack {
        AsyncItemListView()
    }
}

@available(iOS 17, *)
private struct AsyncItemListView: View {
    var body: some View {
        AsyncView(id: "mock-items") {
            try await Task.sleep(for: .seconds(1))
            return Item.createItems()
        } hostedViewGenerator: {
            ItemListView(items: $0)
        } loadingViewGenerator: {
            ProgressView()
        }
    }
}

@available(iOS 17, *)
private struct ItemListView: View {

    @State 
    var items: [Item]
    
    var body: some View {
        InfiniteVerticalScrollView(
            items: $items,
            nextPageFetcher: { _ in
                try await Task.sleep(for: .seconds(2))
                return (Item.createItems(), true)
            },
            itemViewBuilder: { item in
                Text(item.name)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.white)
                    .background(in: RoundedRectangle(cornerRadius: 8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
            }
        )
        .background(Color.init(uiColor: .systemGroupedBackground))
    }
}
@available(iOS 17, *)
struct InfiniteVerticalScrollView<Item: Identifiable, ItemView: View>: View {
    
    init(alignment: HorizontalAlignment = .center,
         spacing: CGFloat? = nil,
         pinnedViews: PinnedScrollableViews = .init(),
         items: Binding<[Item]>,
         nextPageFetcher: @escaping NextPageFetcher,
         @ViewBuilder itemViewBuilder: @escaping ItemViewBuilder) {
        self.alignment = alignment
        self.spacing = spacing
        self.pinnedViews = pinnedViews
        self._items = items
        self.nextPageFetcher = nextPageFetcher
        self.itemViewBuilder = itemViewBuilder
    }
        
    @Binding
    private var items: [Item]
    
    typealias ItemViewBuilder = (Item) -> ItemView
    typealias NextPageFetcher = (Item.ID) async throws -> ([Item], Bool)

    private let itemViewBuilder: ItemViewBuilder
    private let nextPageFetcher: NextPageFetcher
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let pinnedViews: PinnedScrollableViews

    @State
    private var phase: Phase = .idle
    
    @State
    private var scrollPositionItemID: Item.ID?

    @State
    private var error: Swift.Error?

    enum Phase: Equatable {
        case idle
        case noMorePages
        case paging(fromItem: Item.ID)
        
        var isPaging: Bool {
            switch self {
            case .paging:
                return true
            default:
                return false
            }
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: alignment, spacing: spacing, pinnedViews: pinnedViews) {
                ForEach(items) { item in
                    itemViewBuilder(item)
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
            
            if phase.isPaging {
                ProgressView()
            }
        }
        .errorAlert(error: $error)
        .scrollPosition(id: $scrollPositionItemID, anchor: .bottom)
        .animation(.default, value: phase)
        .onChange(of: scrollPositionItemID) { _, newValue in
            if let newValue, newValue == items.last?.id, phase == .idle {
                self.phase = .paging(fromItem: newValue)
            }
        }
        .navigationTitle(scrollPositionItemID.flatMap({String.init(describing: $0)}) ?? "")
        .task(id: phase) {
            guard case let .paging(itemID) = phase else {
                return
            }
            do {
                let (newItems, areThereMorePages) = try await nextPageFetcher(itemID)
                self.items.append(contentsOf: newItems)
                self.phase = areThereMorePages ? .idle : .noMorePages
            } catch {
                self.phase = .idle
                self.error = error
            }
        }
    }
}


private struct Item: Identifiable {
    let name: String
    var id: String { name }
    
    static func createItems() -> [Item] {
        [
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
            Item(name: UUID().uuidString),
        ]
    }
}

#endif
