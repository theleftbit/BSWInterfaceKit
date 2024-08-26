
/// Hook this up in in `AppDelegate.didFinishLaunching`
/// to your preferred tacking framework in order to trace Async operations
public enum AsyncOperationTracer {
    
    public static nonisolated func setOperationDidBegin(_ op: @escaping OperationHandler) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidBegin = op
        }
    }
    
    public static nonisolated func setOperationDidEnd(_ op: @escaping OperationHandler) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidEnd = op
        }
    }
    
    public static nonisolated func setOperationDidFail(_ op: @escaping OperationFailedHandler) {
        Task { @AsyncOperationTracerStorageActor in
            AsyncOperationTracer.operationDidFail = op
        }
    }

    public typealias OperationHandler = @Sendable (Operation) async -> ()
    public typealias OperationFailedHandler = @Sendable (Operation, any Error) async -> ()

    public struct Operation: Sendable {
        
        public let kind: Kind
        public let id: any (Equatable & Sendable)
        
        public enum Kind: Sendable {
            case viewLoading
            case buttonAction
        }
    
        public var traceValue: String {
            switch self.kind {
            case .buttonAction:
                return "async-button-\(self.id)"
            case .viewLoading:
                return "async-view-\(self.id)"
            }
        }
    }
    
    @AsyncOperationTracerStorageActor
    static var operationDidBegin: OperationHandler = { _ in }
    @AsyncOperationTracerStorageActor
    static var operationDidEnd: OperationHandler = { _ in }

    @AsyncOperationTracerStorageActor
    static var operationDidFail: OperationFailedHandler = { _, _ in }
}

@globalActor actor AsyncOperationTracerStorageActor: GlobalActor {
    static let shared = AsyncOperationTracerStorageActor()
}
