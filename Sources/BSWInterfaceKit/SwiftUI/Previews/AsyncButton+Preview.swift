import SwiftUI

@available(iOS 16.0, *)
struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton {
            try await Task.sleep(for: .seconds(1.5))
            struct SomeError: Swift.Error {}
        } label: {
            Label(
                title: { Text("Touch Me") },
                icon: { Image(systemName: "42.circle") }
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .frame(width: 320)
        .font(.headline)
        .asyncButtonLoadingConfiguration(
            message: "Loading...",
            style: .blocking(font: .headline, dimsBackground: true)
        )
    }
}
