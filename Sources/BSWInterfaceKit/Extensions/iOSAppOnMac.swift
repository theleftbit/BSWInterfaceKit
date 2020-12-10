import Foundation

public func isiOSAppOnMac() -> Bool {
    if #available(iOS 14.0, *) {
        return ProcessInfo.processInfo.isiOSAppOnMac
    } else {
        return false
    }
}
