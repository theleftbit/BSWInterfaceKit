import Foundation

public func isiOSAppOnMac() -> Bool {
    #if targetEnvironment(macCatalyst)
    return true
    #else
    if #available(iOS 14.0, *) {
        return ProcessInfo.processInfo.isiOSAppOnMac
    } else {
        return false
    }
    #endif
}
