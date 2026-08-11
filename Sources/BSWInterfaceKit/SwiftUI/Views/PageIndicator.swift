//
//  Created by Michele Restuccia on 22/06/2026.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

/// The native PageTabViewStyle indicator is not rendered consistently by Skip on Android.

public struct PageIndicator: View {
    
    private let itemIDs: [String]
    private let selectedID: String
    private let color: Color
    
    public init(
        itemIDs: [String],
        selectedID: String,
        color: Color = .primary
    ) {
        self.itemIDs = itemIDs
        self.selectedID = selectedID
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(itemIDs.indices, id: \.self) { index in
                Circle()
                    .fill(color.opacity(itemIDs[index] == selectedID ? 1 : 0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
