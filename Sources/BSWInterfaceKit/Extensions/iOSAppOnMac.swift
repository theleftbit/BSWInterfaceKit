import Foundation
import BSWFoundation

public func isiOSAppOnMac() -> Bool {
    ProcessInfo.processInfo.isCatalystOriIOSAppOnMac
}
