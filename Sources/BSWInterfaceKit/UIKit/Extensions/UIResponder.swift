#if canImport(UIKit.UIResponder)

import UIKit

public extension UIResponder {
    
    /// This method transverses the responder chain to find an element
    /// conforming to the generic constraint `T`. For example, say you
    /// have `protocol Foo { func bar(_: Int) } `, you could,
    /// from any `UIResponder`,  do a `(next() as Foo?)?.bar(42)`
    /// to transverse the hierarchy until you find an object matching this requirement.
    func next<T>() -> T? {
        guard let responder = self.next else {
            return nil
        }
        
        return (responder as? T) ?? responder.next()
    }
}

#endif
