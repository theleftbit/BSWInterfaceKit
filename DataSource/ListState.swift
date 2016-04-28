//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

public enum ListState<T> {
    case Failure(error: ErrorType)
    case Loading(message: String)
    case Loaded(data: [T])

    var isLoading: Bool {
        switch self {
        case .Loading(_):
            return true
        default:
            return false
        }
    }

    var isEmpty: Bool {
        switch self {
        case .Loaded(let array):
            return array.count == 0
        default:
            return false
        }
    }
}
