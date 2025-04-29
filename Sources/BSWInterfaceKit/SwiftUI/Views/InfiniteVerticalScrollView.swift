import SwiftUI
import Combine

#if canImport(Darwin)
@available(iOS 18, macOS 15, watchOS 11, *)
#Preview {
    
    @Previewable
    @State
    var items: [Item] = Item.createItems()
    
    let isUpwards = true

    struct Item: Identifiable {
        let name: String
        var id: String { name }
        
        static func createItems() -> [Item] {
            [
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
                generateItem(),
            ]
        }
        
        static func generateItem() -> Item {
            Item(name: randomAlphaNumericString(length: Int.random(in: 1...200)))
        }
        
        private static func randomAlphaNumericString(length: Int) -> String {
            let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let allowedCharsCount = UInt32(allowedChars.count)
            var randomString = ""

            for _ in 0 ..< length {
                let randomNum = Int(arc4random_uniform(allowedCharsCount))
                let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
                let newCharacter = allowedChars[randomIndex]
                randomString += String(newCharacter)
            }

            return randomString
        }
    }

    return NavigationStack {
        InfiniteVerticalScrollView(
            direction: isUpwards ? .upwards : .downwards,
            items: $items,
            nextPageFetcher: { _ in
                try await Task.sleep(for: .seconds(2))
                return (Item.createItems(), true)
            },
            itemViewBuilder: { item in
                Text(item.name)
                    .font(.title)
                    .padding(8)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.white)
                    .background(in: RoundedRectangle(cornerRadius: 8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
            }
        )
        .contentMargins(.all, 16, for: .scrollContent)
        .safeAreaInset(edge: .top, spacing: 0) {
            Rectangle()
                .fill(Color.red)
                .frame(height: 40)
                .overlay {
                    Text("Insert Item")
                }
                .onTapGesture {
                    withAnimation {
                        if isUpwards {
                            items.append(Item.generateItem())
                        } else {
                            items.insert(Item.generateItem(), at: 0)
                        }
                    }
                }
        }
#if os(iOS)
        .background(Color(uiColor: .systemGray4))
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationTitle("Hello")
    }
}
#endif

@available(iOS 18, macOS 15, watchOS 11, *)
public struct InfiniteVerticalScrollView<Item: Identifiable & Sendable, ItemView: View>: View where Item.ID : Sendable {
    
    public init(
        direction: Direction = .downwards,
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
    
    public enum Direction {
        case downwards
        case upwards
    }
    
    public typealias ItemViewBuilder = (Item) -> ItemView
    public typealias NextPageFetcher = (Item.ID) async throws -> ([Item], Bool)
    
    private let itemViewBuilder: ItemViewBuilder
    private let nextPageFetcher: NextPageFetcher
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let pinnedViews: PinnedScrollableViews
    private let direction: Direction
    
    @Binding
    private var items: [Item]
    
    @State
    private var phase: Phase = .idle
    
    @State
    private var scrollPosition = ScrollPosition(idType: Item.ID.self)
    
    @State
    private var isScrolling = false
    
    @State
    private var visibleItemIDs: [Item.ID] = []
    
    @State
    private var error: Swift.Error?
    
    @Environment(\.redactionReasons)
    private var redactionReasons
    
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
    
    public var body: some View {
        ScrollView(.vertical) {
            if direction == .upwards, phase.isPaging {
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
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .scrollPosition($scrollPosition, anchor: (direction == .downwards) ? .bottom : .top)
        .onScrollTargetVisibilityChange(idType: Item.ID.self, threshold: 0.9) { ids in
            if redactionReasons.contains(.placeholder) { return }
            self.visibleItemIDs = ids
        }
        .scrollDismissesKeyboard(.interactively)
        .onScrollPhaseChange { _, newPhase in
            self.isScrolling = (newPhase != .idle)
        }
        .onChange(of: visibleItemIDs) { _, newValue in
            if let anchorItemID, newValue.contains(anchorItemID), phase == .idle, isScrolling {
                let newPhase = Phase.paging(fromItem: anchorItemID)
                self.phase = newPhase
            }
        }
        .task(id: phase) {
            await fetchData()
        }
#if canImport(UIKit.UIResponder)
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            if newIsKeyboardVisible, direction == .upwards {
                withAnimation(.default) {
                    self.scrollPosition.scrollTo(id: items.last?.id, anchor: .bottom)
                }
            }
        }
#endif
        .errorAlert(error: $error)
        .onChange(of: items.map { $0.id }) { oldValue, newValue in
            guard direction == .upwards,
                  let newValueID = newValue.last,
                  let oldValueID = oldValue.last,
                  newValueID != oldValueID else {
                return
            }
            Task { @MainActor in
                try await Task.sleep(for: .seconds(0.3))
                withAnimation(.default) {
                    self.scrollPosition.scrollTo(id: newValueID, anchor: .bottom)
                }
            }
        }
    }
    
    private func fetchData() async {
        if redactionReasons.contains(.placeholder) { return }
        try? await Task.sleep(for: .seconds(0.15))
        guard case let .paging(itemID) = phase else {
            return
        }
        do {
            let (newItems, areThereMorePages) = try await nextPageFetcher(itemID)
            withAnimation {
                self.phase = areThereMorePages ? .idle : .noMorePages
            } completion: {
                switch direction {
                case .downwards:
                    self.items.append(contentsOf: newItems)
                case .upwards:
                    self.items.insert(contentsOf: newItems, at: 0)
                }
                self.scrollPosition.scrollTo(id: itemID, anchor: (direction == .downwards) ? .bottom : .top)
            }
        } catch {
            self.phase = .idle
            if error is CancellationError {
                return
            }
            self.error = error
        }
    }
    
    private var anchorItemID: Item.ID? {
        switch direction {
        case .downwards:
            return items.last?.id
        case .upwards:
            return items.first?.id
        }
    }
    
#if canImport(UIKit.UIResponder)
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
#endif
}
