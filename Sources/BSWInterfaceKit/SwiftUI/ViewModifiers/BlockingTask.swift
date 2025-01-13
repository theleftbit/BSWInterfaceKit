//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 16.0, *)
#Preview {
    SampleView()
}

@available(iOS 16.0, *)
private struct SampleView: View {
    
    struct SomeError: Swift.Error {}
    
    @State
    var perform: Bool = false
    
    var body: some View {
        Button {
            perform = true
        } label: {
            Text("try")
        }
        .performBlockingTask(readyToPerform: $perform) {
            try await Task.sleep(for: .seconds(5))
            throw SomeError()
        }
    }
}

public typealias AsyncBlockingTask = @MainActor () async throws -> ()
public typealias AsyncBlockingTaskWithValue<T: Equatable> = @MainActor (T) async throws -> ()

public extension View {
    
    func performBlockingTask(readyToPerform: Binding<Bool>, task: @escaping AsyncBlockingTask) -> some View {
        self.modifier(PerformBlockingModifier(readyToPerform: readyToPerform, task: task))
    }

    func performBlockingTask<T: Equatable>(value: Binding<T?>, task: @escaping AsyncBlockingTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifier(value: value, task: task))
    }
}

private struct PerformBlockingModifier: ViewModifier {
    
    @Binding
    var readyToPerform: Bool
    
    let task: AsyncBlockingTask
    
    private enum Phase {
        case idle
        case loading
    }
        
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: readyToPerform) {
                guard readyToPerform else { return }
                async let ___vc = SwiftUIHUD.presentHUDViewController()
                do {
                    try await task()
                } catch {
                    taskError = error
                }
                let vc = await ___vc
                if let vc {
                    await SwiftUIHUD.dismissHUDViewController(hudVC: vc)
                }
                self.readyToPerform = false
            }
            .errorAlert(error: $taskError)
    }
}

private struct PerformEquatableBlockingModifier<T: Equatable>: ViewModifier {
    
    @Binding
    var value: T?
    
    let task: AsyncBlockingTaskWithValue<T>
            
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                async let ___vc = SwiftUIHUD.presentHUDViewController()
                do {
                    try await task(value)
                } catch {
                    taskError = error
                }
                let vc = await ___vc
                if let vc {
                    await SwiftUIHUD.dismissHUDViewController(hudVC: vc)
                }
                self.value = nil
            }
            .errorAlert(error: $taskError)
    }
}

#endif
