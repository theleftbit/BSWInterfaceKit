//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation

//MARK:- Protocols

/// Describes an object that can be configured with given data.
@available(swift, deprecated: 6.0, obsoleted: 6.1, message: "Please use UIContentConfiguration instead")
@MainActor
public protocol ViewModelConfigurable: AnyObject {
    associatedtype VM
    func configureFor(viewModel: VM)
}

/// Describes an object that can be reused and configured with given data.
@available(swift, deprecated: 6.0, obsoleted: 6.1, message: "Please use UIContentConfiguration instead")
@MainActor
public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

//MARK:- Extensions

extension ViewModelReusable {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!

    }
    public static var reuseType: ReuseType {
        return .classReference(self)
    }
}

//MARK:- Types

public enum ReuseType {
    case nib(UINib)
    case classReference(AnyClass)
}

#endif
