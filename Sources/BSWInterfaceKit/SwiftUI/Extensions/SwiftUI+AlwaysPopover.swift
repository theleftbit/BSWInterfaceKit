#if canImport(Darwin)
import SwiftUI

#Preview {
    ContentView(items: [
        .init(
            id: 0,
            systemImageName: "person.circle",
            description: "Description"
        )
    ])
}

struct ContentView: View {
    
    struct Item: Identifiable {
        let id: Int
        let systemImageName: String
        let description: String
    }
    var items: [Item]
    
    @State
    var presentingDetailsOfItem: Item?
    
    var body: some View {
        HStack {
            ForEach(items, id: \.id) { item in
                Button {
                    presentingDetailsOfItem = item
                } label: {
                    Image(systemName: item.systemImageName)
                }
                .popover(item: $presentingDetailsOfItem) { item in
                    Text(item.description)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
    }
}
#endif
