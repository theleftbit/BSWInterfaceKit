
/// Hook this up in in `AppDelegate.didFinishLaunching`
/// to your preferred tacking framework in order to trace Async operations
public enum AsyncOperationTracer {
    
    public static nonisolated func setOperationDidBegin(_ op: @escaping Operation) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidBegin = op
        }
    }
    
    public static nonisolated func setOperationDidEnd(_ op: @escaping Operation) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidEnd = op
        }
    }
    
    public static nonisolated func setOperationDidFail(_ op: @escaping OperationFailed) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidFail = op
        }
    }

    public typealias Operation = @Sendable (any OperationID) async -> ()
    public typealias OperationFailed = @Sendable (any OperationID, any Error) async -> ()

    public typealias OperationID = (Equatable & Sendable)
    
    @AsyncOperationTracerStorageActor
    static var operationDidBegin: Operation = { _ in }
    @AsyncOperationTracerStorageActor
    static var operationDidEnd: Operation = { _ in }

    @AsyncOperationTracerStorageActor
    static var operationDidFail: OperationFailed = { _, _ in }
}

@globalActor private actor AsyncOperationTracerStorageActor: GlobalActor {
    static let shared = AsyncOperationTracerStorageActor()
}
