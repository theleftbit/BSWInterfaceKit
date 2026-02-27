//
//  Created by Michele Restuccia on 27/2/26.
//

import SwiftUI

#if canImport(UIKit)

private struct Item: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let icon: Image?
}

#Preview {
    
    @Previewable
    @State
    var items: [Item] = [
        .init(
            id: "milan",
            title: "AC Milan ❤️🖤",
            detail: "Rossoneri. Sette Champions. Incancellabile. Controlled by `isSwipeDisabled`",
            icon: Image(systemName: "flame.fill")
        ),
        .init(
            id: "juve",
            title: "Juventus",
            detail: "Bianconeri. Vincere non è importante, è l’unica cosa.",
            icon: Image(systemName: "shield.fill")
        ),
        .init(
            id: "inter",
            title: "Inter",
            detail: "Nerazzurri. Pazza Inter.",
            icon: Image(systemName: "bolt.fill")
        ),
        .init(
            id: "real_madrid",
            title: "Real Madrid",
            detail: "Blancos. Reyes de Europa.",
            icon: Image(systemName: "crown.fill")
        ),
        .init(
            id: "barcelona",
            title: "FC Barcelona",
            detail: "Blaugrana. Més que un club.",
            icon: Image(systemName: "circle.grid.cross.fill")
        ),
        .init(
            id: "atletico",
            title: "Atlético de Madrid",
            detail: "Colchoneros. Coraje y corazón.",
            icon: Image(systemName: "heart.fill")
        ),
        .init(
            id: "bayern",
            title: "Bayern München",
            detail: "Rekordmeister. Dominio alemán.",
            icon: Image(systemName: "star.fill")
        ),
        .init(
            id: "liverpool",
            title: "Liverpool",
            detail: "Reds. You'll Never Walk Alone.",
            icon: Image(systemName: "music.note.list")
        ),
        .init(
            id: "manchester",
            title: "Manchester United",
            detail: "Red Devils. Theatre of Dreams.",
            icon: Image(systemName: "suit.spade.fill")
        )
    ]
    
    NavigationStack {
        ScrollView {
            SwipeableListViewV2(
                items: $items,
                isSwipeDisabled: { $0.id == "milan" },
                rowContent: { item in
                    /// This is intentionally a Button to prove the swipe still works.
                    Button {} label: {
                        HStack(alignment: .top, spacing: 16) {
                            if let icon = item.icon {
                                icon
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(8)
                                    .background(.black.opacity(0.15), in: Circle())
                                    .foregroundStyle(.black)
                                    .frame(width: 44, height: 44)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .bold()
                                    .foregroundStyle(.black)
                                
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(.black.opacity(0.5))
                            }
                            .multilineTextAlignment(.leading)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(16)
                    }
                    .background(Color(uiColor: UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(.separator.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                },
                onDelete: { item in
                    withAnimation(.swipeable) {
                        items.removeAll { $0.id == item.id }
                    }
                }
            )
            .padding(16)
        }
        .navigationTitle("Top Football Teams")
        .background(Color(uiColor: UIColor.secondarySystemBackground))
    }
}
#endif

struct SwipeableListViewV2<Item: Identifiable & Equatable, RowContent: View>: View {
    
    @Binding
    var items: [Item]
    
    @State
    var rowHeights: [AnyHashable: Double] = [:]
    
    @State
    var estimatedRowHeight: Double = 84
    
    private let spacing: Double
    private let rowContent: (Item) -> RowContent
    private let isSwipeDisabled: (Item) -> Bool
    private let onDelete: (Item) -> ()
    
    public init(
        spacing: Double = 4,
        items: Binding<[Item]>,
        isSwipeDisabled: @escaping (Item) -> Bool = { _ in false },
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        onDelete: @escaping (Item) -> ()
    ) {
        self.spacing = spacing
        self._items = items
        self.isSwipeDisabled = isSwipeDisabled
        self.rowContent = rowContent
        self.onDelete = onDelete
    }
    
    var body: some View {
        List {
            ForEach(items) {
                itemView($0)
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .frame(height: listHeight)
        .onPreferenceChange(RowHeightKey.self) { values in
            let validIDs = Set(items.map { AnyHashable($0.id) })
            rowHeights = values.filter { validIDs.contains($0.key) }
            if let first = rowHeights.values.first {
                estimatedRowHeight = first
            }
        }
    }
    
    @ViewBuilder
    private func itemView(_ item: Item) -> some View {
        rowContent(item)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.vertical, spacing)
            .listRowInsets(.init())
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if !isSwipeDisabled(item) {
                    Button(role: .destructive) {
                        onDelete(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: RowHeightKey.self,
                        value: [AnyHashable(item.id): proxy.size.height]
                    )
                }
            }
    }
    
    private var listHeight: Double {
        let measured = rowHeights.values.reduce(0, +)
        let missing = max(0, items.count - rowHeights.count)
        return max(1, measured + (CGFloat(missing) * estimatedRowHeight))
    }
    
    private struct RowHeightKey: PreferenceKey {
        static var defaultValue: [AnyHashable: Double] { [:] }
        
        static func reduce(
            value: inout [AnyHashable: Double],
            nextValue: () -> [AnyHashable: Double]
        ) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
}
