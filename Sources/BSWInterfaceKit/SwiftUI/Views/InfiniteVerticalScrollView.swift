#if canImport(UIKit)
import SwiftUI

@available(iOS 17, *)
#Preview {
    NavigationStack {
        ItemListView(items: Item.createItems())
    }
}

@available(iOS 17, *)
private struct ItemListView: View {

    @State
    var items: [Item]
    
    var body: some View {
        InfiniteVerticalScrollView(
            direction: .downwards,
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
    
    init(direction: Direction = .downwards,
         alignment: HorizontalAlignment = .center,
         spacing: CGFloat? = nil,
         pinnedViews: PinnedScrollableViews = .init(),
         items: Binding<[Item]>,
         nextPageFetcher: @escaping NextPageFetcher,
         @ViewBuilder itemViewBuilder: @escaping ItemViewBuilder) {
        self.alignment = alignment
        self.spacing = spacing
        self.pinnedViews = pinnedViews
        self.direction = direction
        self._items = items
        self.nextPageFetcher = nextPageFetcher
        self.itemViewBuilder = itemViewBuilder
    }
        
    
    enum Direction {
        case downwards
        
        @available(iOS 18, *)
        case upwards
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
    private let direction: Direction

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
            
            if #available(iOS 18, *), direction == .upwards, phase.isPaging {
                ProgressView()
            }

            LazyVStack(alignment: alignment, spacing: spacing, pinnedViews: pinnedViews) {
                ForEach(items) { item in
                    itemViewBuilder(item)
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
            
            if direction == .downwards, phase.isPaging {
                ProgressView()
            }
        }
        .scrollPosition(
            id: $scrollPositionItemID,
            anchor: (direction == .downwards) ? .bottom : .top
        )
        .defaultScrollAnchor((direction == .downwards) ? .top : .bottom)
        .onChange(of: scrollPositionItemID) { _, newValue in
            if let newValue, newValue == anchorItemID, phase == .idle {
                self.phase = .paging(fromItem: newValue)
            }
        }
        .navigationBarTitle(Text(scrollPositionItemID.flatMap({String.init(describing: $0)}) ?? "nil"), displayMode: .inline)
        .task(id: phase) {
            guard case let .paging(itemID) = phase else {
                return
            }
            do {
                let (newItems, areThereMorePages) = try await nextPageFetcher(itemID)
                switch direction {
                case .downwards:
                    self.items.append(contentsOf: newItems)
                case .upwards:
                    self.items.insert(contentsOf: newItems, at: 0)
                }
                self.phase = areThereMorePages ? .idle : .noMorePages
            } catch {
                self.phase = .idle
                self.error = error
            }
        }
        .errorAlert(error: $error)
    }
    
    private var anchorItemID: Item.ID? {
        switch direction {
        case .downwards:
            return items.last?.id
        case .upwards:
            return items.first?.id
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
