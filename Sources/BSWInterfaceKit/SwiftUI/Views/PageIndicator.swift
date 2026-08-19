//
//  Created by Michele Restuccia on 22/06/2026.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

/// Uses native page indicators on iOS and a custom indicator on Android,
/// where white native dots are not visible on white backgrounds.

public extension View {
    
    @ViewBuilder
    func platformPageIndicator(itemIDs: [String], selectedID: String) -> some View {
        #if canImport(UIKit)
        tabViewStyle(.page(indexDisplayMode: .always))
        #elseif os(Android)
        tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(alignment: .bottom) {
                PageIndicator(
                    itemIDs: itemIDs,
                    selectedID: selectedID
                )
                .padding(.bottom, 16)
            }
        #else
        self
        #endif
    }
}

struct PageIndicator: View {
    
    private let itemIDs: [String]
    private let selectedID: String
    private let color: Color
    
    init(
        itemIDs: [String],
        selectedID: String,
        color: Color = .primary
    ) {
        self.itemIDs = itemIDs
        self.selectedID = selectedID
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(itemIDs.indices, id: \.self) { index in
                Circle()
                    .fill(color.opacity(itemIDs[index] == selectedID ? 1 : 0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
