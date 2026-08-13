import Foundation
import BSWFoundation

/// - Returns: Wheter the current app is being run on a Mac.
public func isiOSAppOnMac() -> Bool {
    ProcessInfo.processInfo.isCatalystOriIOSAppOnMac
}
