import SwiftUI
import BSWInterfaceKit

@available(iOS 16.0, *)
struct DemoView: View {
    
    @State var presentSheet = false

    var body: some View {
        Button("Present Sheet") {
            presentSheet = true
        }
        .dynamicHeightSheet(isPresented: $presentSheet) {
            ContentView()
        }
    }
}

@available(iOS 16.0, *)
private struct ContentView: View {
    var body: some View {
        VStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac bibendum est. Donec tincidunt ligula sit amet ipsum vehicula vehicula. Vestibulum ultrices arcu sit amet aliquam dictum.")
                .fixedSize(horizontal: false, vertical: true)
        }
            .padding()
    }
}

struct IntrinsicHeightDetentView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
