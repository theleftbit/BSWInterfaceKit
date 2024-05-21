import SwiftUI

@available(iOS 17, macOS 14, *)
#Preview {
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
  .padding()
  .font(.headline)
  .asyncButtonLoadingConfiguration(
      message: "Loading...",
      style: .nonblocking
  )
}
