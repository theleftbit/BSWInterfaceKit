
import SwiftUI

/// Example of how to reload `AsyncView`
/// when the ID of the operation changes.

@available(iOS 16.0, *)
struct AsyncContentView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncContentView()
    }
}

@available(iOS 16.0, *)
private struct AsyncContentView: View {
    
    @State var asyncViewID: String = "default-value"
    
    var body: some View {
        
        VStack {
            HStack {
                Button("Swap1") {
                    asyncViewID = "swap-1"
                }
                Button("Swap2") {
                    asyncViewID = "swap-2"
                }
            }
            Spacer()
            AsyncView(
                id: $asyncViewID,
                dataGenerator: {
                    await generateData(forQuery: asyncViewID)
                },
                hostedViewGenerator: {
                    ContentView(data: $0)
                }
            )
            .border(Color.red)
        }
    }

    func generateData(forQuery query: String) async -> String {
        /// On a real app, this method will call a Web Server to fetch
        /// real data, but here we're mocking what to return in
        /// depending on the supplied ID. This is just mock logic.
        try? await Task.sleep(for: .milliseconds(600))
        switch query {
        case "default-value":
            return "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        case "swap-1":
            return "Etiam pharetra maximus felis ac commodo. Proin tortor ex, ornare quis bibendum sed, mollis nec est"
        case "swap-2":
            return "Nam vel nunc ipsum. Nunc in magna sed nisi dapibus feugiat in vel elit"
        default:
            return AsyncContentView.ContentView.generatePlaceholderData()
        }
    }

    struct ContentView: View, PlaceholderDataProvider {
        let data: String
        
        var body: some View {
            Text(data)
                .font(.largeTitle)
                .padding()
        }
        
        static func generatePlaceholderData() -> String {
            "Morbi ullamcorper interdum ex, non feugiat neque hendrerit eu."
        }
    }
}
