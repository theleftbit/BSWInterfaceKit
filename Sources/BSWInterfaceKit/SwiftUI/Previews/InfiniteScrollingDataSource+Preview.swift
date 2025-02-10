#if DEBUG

/// Example of how to use `InfiniteScrollingDataSource`
/// Note: as of Xcode 14.3.1 this code is not transitioning to .loaded
/// but if you copy/paste the code in an app, it'll work correctly
import SwiftUI

@available(iOS 17, macOS 14, watchOS 10, *)
#Preview {
    AsyncView(id: "mock-items") {
        try await ItemInfiniteDataSource()
    } hostedViewGenerator: {
        ItemListView(dataSource: $0)
    } loadingViewGenerator: {
        ProgressView()
    }

}

@available(iOS 17, macOS 14, watchOS 10, *)
private class ItemInfiniteDataSource: InfiniteScrollingDataSource<Item> {
    init() async throws {
        try await super.init { pageNumber in
            try await Task.sleep(for: .seconds(1))
            let products = [
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
            let areThereMorePages = true
            return (products, areThereMorePages)
        }
    }
}

@available(iOS 17, macOS 14, watchOS 10, *)
private struct ItemListView: View {

    @StateObject var dataSource: ItemInfiniteDataSource

    var body: some View {
        List {
            Section {
                ForEach(dataSource) { item in
                    Text(item.name)
                }
            } footer: {
                FooterView(dataSource: dataSource)
            }
        }
    }

    struct FooterView: View {

        @ObservedObject var dataSource: ItemInfiniteDataSource

        var body: some View {
            HStack(spacing: 8) {
                Text("Products count: \(dataSource.items.count)")
                if dataSource.state == .loading {
                    Text("🔄")
                } else {
                    Text("✅")
                }
            }
        }
    }
}

private struct Item: Identifiable {
    let name: String
    var id: String { name }
}

#endif
