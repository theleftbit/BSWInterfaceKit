//
//  Created by Michele Restuccia on 24/2/26.
//

import SwiftUI

#if canImport(Darwin)

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
    DemoSwipeableListView()
}

private struct DemoSwipeableListView: View {
    
    struct Item: Identifiable, Equatable {
        let id: String
        let title: String
        let detail: String
        let icon: Image?
    }
    
    @State
    var items: [Item] = [
        .init(
            id: "milan",
            title: "AC Milan ❤️🖤",
            detail: "Rossoneri. Sette Champions.",
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
            detail: "Nerazzurri. Pazza Inter",
            icon: Image(systemName: "bolt.fill")
        )
    ]
    
    var body: some View {
        SwipeableListView(
            items: items,
            isSwipeDisabled: { $0.id == "milan" },
            rowContent: { itemView($0) },
            onDelete: { id in
                withAnimation(.swipeable) {
                    items.removeAll { $0.id == id }
                }
            }
        )
        .padding(16)
        .background(.primary)
    }
    
    @ViewBuilder
    private func itemView(_ item: Item) -> some View {
        /// This is intentionally a Button to prove the swipe still works.
        Button {} label: {
            HStack(alignment: .top, spacing: 16) {
                if let icon = item.icon {
                    icon
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(.secondary.opacity(0.15), in: Circle())
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title).bold()
                    Text(item.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.separator.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        
    }
}

#endif

// MARK: - SwipeableListView

public struct SwipeableListView<Item: Identifiable, RowContent: View>: View {
    
    private let spacing: Double
    
    private let items: [Item]
    private let rowContent: (Item) -> RowContent
    private let isSwipeDisabled: (Item) -> Bool
    
    public typealias ID = Item.ID
    public typealias DeleteHandler = (ID) -> Void
    private let onDelete: DeleteHandler
    
    @State
    var openRowID: ID?
    
    public init(
        spacing: Double = 4,
        items: [Item],
        isSwipeDisabled: @escaping (Item) -> Bool = { _ in false },
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        onDelete: @escaping DeleteHandler
    ) {
        self.spacing = spacing
        self.items = items
        self.isSwipeDisabled = isSwipeDisabled
        self.rowContent = rowContent
        self.onDelete = onDelete
    }
    
    public var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(items) { item in
                SwipeableRow(
                    id: item.id,
                    isDisabled: isSwipeDisabled(item),
                    openRowID: $openRowID,
                    content: { rowContent(item) },
                    onDelete: onDelete
                )
                .transition(.swipeableRow)
            }
        }
    }
}

// MARK: - SwipeableRow

struct SwipeableRow<ID: Hashable, Content: View>: View {
    
    @Binding
    var openRowID: ID?
    
    @State
    var baseOffsetX: Double = 0
    
    @State
    var dragOffsetX: Double = 0
    
    private let id: ID
    private let onDelete: (ID) -> ()
    private let content: () -> Content
    private let isDisabled: Bool
    
    init(
        id: ID,
        isDisabled: Bool,
        openRowID: Binding<ID?>,
        @ViewBuilder content: @escaping () -> Content,
        onDelete: @escaping (ID) -> Void,
    ) {
        self.id = id
        self.isDisabled = isDisabled
        self._openRowID = openRowID
        self.content = content
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                actionsView
            }
            #if os(Android)
            .zIndex(baseOffsetX != 0 ? 1.0 : 0.0)
            #endif

            content()
                .contentRectangleShape()
                .offset(x: effectiveOffsetX)
                .animation(.swipeable, value: effectiveOffsetX)
                #if canImport(Darwin)
                .highPriorityGesture(dragGesture)
                #else
                .zIndex(baseOffsetX != 0 ? 0.0 : 1.0)
                .gesture(dragGesture)
                #endif
        }
        .contentRectangleShape()
        .onChange(of: openRowID) { _, newValue in
            guard newValue != id, baseOffsetX != 0 else { return }
            close(animated: true)
        }
        .onChange(of: isDisabled) { _, newValue in
            close(animated: true)
        }
    }
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var actionsView: some View {
        HStack(spacing: 16) {
            Button {
                onDelete(id)
            } label: {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.18))
                        .frame(
                            width: Constants.actionButtonSize,
                            height: Constants.actionButtonSize
                        )
                    
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.red)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, Constants.trailingPadding)
        .frame(width: actionTrayWidth, alignment: .trailing)
    }
    
    // MARK: - Gesture
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                guard !isDisabled else { return }
                let x = value.translation.width
                let y = value.translation.height
                guard abs(x) > abs(y) else { return }
                dragOffsetX = x
            }
            .onEnded { value in
                guard !isDisabled else {
                    finishDrag()
                    return
                }
                defer { finishDrag() }
                
                let x = value.translation.width
                let predicted = x + (value.predictedEndTranslation.width - x) * 0.25
                guard x <= 0 || predicted <= 0 else {
                    closeAndClearOpen(animated: true)
                    return
                }
                if effectiveOffsetX <= Constants.deleteThreshold || predicted <= Constants.deleteThreshold {
                    closeAndClearOpen(animated: false)
                    onDelete(id)
                    return
                }
                if effectiveOffsetX <= Constants.openThreshold || predicted <= Constants.openThreshold {
                    withAnimation(.swipeable) { baseOffsetX = openSnapX }
                    openRowID = id
                } else {
                    closeAndClearOpen(animated: true)
                }
            }
    }
    
    private func close(animated: Bool) {
        if animated {
            withAnimation(.swipeable) { baseOffsetX = 0 }
        } else {
            baseOffsetX = 0
        }
    }
    
    private func clearOpenIfNeeded() {
        if openRowID == id {
            openRowID = nil
        }
    }
    
    private func closeAndClearOpen(animated: Bool) {
        close(animated: animated)
        clearOpenIfNeeded()
    }
    
    private func finishDrag() {
        dragOffsetX = 0
    }
    
    private var openSnapX: Double {
        -actionTrayWidth
    }
    
    private var effectiveOffsetX: Double {
        clamp(baseOffsetX + dragOffsetX, min: openSnapX - 80, max: 0)
    }
    
    private var actionTrayWidth: Double {
        Constants.actionButtonSize + (Constants.trailingPadding * 2)
    }
    
    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}

private enum Constants {
    static let trailingPadding: Double = 16
    static let actionButtonSize: Double = 44
    static let openThreshold: Double = -60
    static let deleteThreshold: Double = -240
}

// MARK: - Extensions

extension Animation {
    static var swipeable: Animation {
        .interactiveSpring(response: 0.25, dampingFraction: 0.92)
    }
}

extension AnyTransition {
    static var swipeableRow: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
