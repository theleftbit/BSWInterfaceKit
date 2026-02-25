//
//  Created by Michele Restuccia on 24/2/26.
//

import SwiftUI

#if canImport(UIKit)

// MARK: - Previews

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
            SwipeableListView(
                items: items,
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
                onDelete: { id in
                    withAnimation(.swipeable) {
                        items.removeAll { $0.id == id }
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

// MARK: - SwipeableListView

public struct SwipeableListView<Item: Identifiable, RowContent: View>: View {
    
    @State
    var items: [Item]
    
    @State
    var openRowID: ID?
    
    private let spacing: Double
    
    private let rowContent: (Item) -> RowContent
    private let isSwipeDisabled: (Item) -> Bool
    
    public typealias ID = Item.ID
    public typealias Handler = (ID) -> ()
    private let onDelete: Handler
    
    public init(
        spacing: Double = 4,
        items: [Item],
        isSwipeDisabled: @escaping (Item) -> Bool = { _ in false },
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        onDelete: @escaping Handler
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
                    handler: { id in
                        /// Remove locally to keep UI consistency while
                        /// the parent-owned source of truth updates.
                        onDelete(id)
                        withAnimation(.swipeable) {
                            items.removeAll { $0.id == id }
                        }
                    }
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
    private let isDisabled: Bool
    private let content: () -> Content
    private let handler: (ID) -> ()
    
    init(
        id: ID,
        isDisabled: Bool,
        openRowID: Binding<ID?>,
        @ViewBuilder content: @escaping () -> Content,
        handler: @escaping (ID) -> Void
    ) {
        self.id = id
        self.isDisabled = isDisabled
        self._openRowID = openRowID
        self.content = content
        self.handler = handler
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            actionsView
            contentView
        }
        .onChange(of: openRowID) { _, newValue in
            guard newValue != id, (baseOffsetX != 0 || dragOffsetX != 0) else { return }
            close(animated: true)
            dragOffsetX = 0
        }
        .onChange(of: isDisabled) { _, newValue in
            guard newValue else { return }
            close(animated: true, clearOpen: true)
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        content()
            .contentRectangleShape()
            .offset(x: effectiveOffsetX)
            .animation(.swipeable, value: effectiveOffsetX)
            .zIndex(baseOffsetX != 0 ? 0 : 1)
            .overlay(alignment: .trailing) {
                if !isDisabled {
                    Color.clear
                        .frame(width: Constants.swipeActivationWidth)
                        .contentRectangleShape()
                        .gesture(dragGesture)
                        .zIndex(999)
                }
            }
    }
    
    @ViewBuilder
    private var actionsView: some View {
        HStack(spacing: 16) {
            Button {
                handler(id)
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
        }
        .frame(width: Constants.swipeActivationWidth, alignment: .trailing)
        .opacity(revealProgress)
        .zIndex(baseOffsetX != 0 ? 1 : 0)
    }
    
    // MARK: - Gesture
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                guard !isDisabled else { return }
                let x = value.translation.width
                let y = value.translation.height
                guard abs(x) > abs(y), x <= 0 else { return }
                if openRowID != id { openRowID = id }
                dragOffsetX = x
            }
            .onEnded { value in
                guard !isDisabled else {
                    dragOffsetX = 0
                    return
                }
                defer { dragOffsetX = 0 }

                let x = value.translation.width
                let predicted = x + (value.predictedEndTranslation.width - x) * 0.25
                guard x <= 0 || predicted <= 0 else {
                    close(animated: true, clearOpen: true)
                    return
                }
                if effectiveOffsetX <= -Constants.destructiveSwipeThreshold || predicted <= -Constants.destructiveSwipeThreshold {
                    close(animated: false, clearOpen: true)
                    handler(id)
                    return
                }
                if effectiveOffsetX <= -Constants.swipeActivationWidth || predicted <= -Constants.swipeActivationWidth {
                    withAnimation(.swipeable) { baseOffsetX = openSnapX }
                    openRowID = id
                } else {
                    close(animated: true, clearOpen: true)
                }
            }
    }

    private func close(animated: Bool, clearOpen: Bool = false) {
        if animated {
            withAnimation(.swipeable) { baseOffsetX = 0 }
        } else {
            baseOffsetX = 0
        }
        if clearOpen && openRowID == id {
            openRowID = nil
        }
    }

    private var openSnapX: Double { -Constants.swipeActivationWidth }
    
    private var revealProgress: Double {
        (-effectiveOffsetX / Constants.swipeActivationWidth).clamped(to: 0...1)
    }
    private var effectiveOffsetX: Double {
        (baseOffsetX + dragOffsetX).clamped(to: (openSnapX - Constants.swipeOvershoot)...0)
    }
}

private enum Constants {

    /// Width of the invisible swipe hit area on the trailing edge.
    /// Defines how far the user must drag horizontally for the swipe
    /// gesture to be considered intentional.
    static let swipeActivationWidth: Double = 60

    /// Maximum extra distance the row can be dragged beyond its final
    /// resting position. Provides a subtle elastic "overshoot" effect
    /// during the swipe interaction.
    static let swipeOvershoot: Double = 80

    /// Horizontal distance required to trigger a destructive action
    /// (e.g. delete) when releasing the swipe gesture.
    /// Larger than the activation width to avoid accidental deletions.
    static let destructiveSwipeThreshold: Double = 260

    /// Padding applied to the action tray to keep destructive
    /// actions visually separated from the row content.
    static let padding: Double = 16

    /// Size of the circular action button (e.g. delete).
    /// Aligned with platform touch target recommendations.
    static let actionButtonSize: Double = 44
}

// MARK: - Extensions

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

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
