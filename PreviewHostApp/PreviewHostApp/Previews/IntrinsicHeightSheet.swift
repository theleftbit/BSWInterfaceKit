import SwiftUI
import BSWInterfaceKit

@available(iOS 16.0, *)
struct DemoView: View {
    
    @State var presentSheet = false
    
    var body: some View {
        Button("Present Sheet") {
            presentSheet = true
        }
        .intrinsicHeightSheet(isPresented: $presentSheet) {
            ContentView()
        }
        .task {
            presentSheet = true
        }

    }

    struct ContentView: View {
        var body: some View {
            VStack {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac bibendum est. Donec tincidunt ligula sit amet ipsum vehicula vehicula. Vestibulum ultrices arcu sit amet aliquam dictum.")
            }
            .padding()
        }
    }
}

struct IntrinsicHeightSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
