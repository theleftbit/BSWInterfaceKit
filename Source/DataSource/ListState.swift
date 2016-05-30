//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

/**
 Represents the different states that a list can be
 
 - Loading: The data is being remotely fetched.
 - Loaded:  The data is loaded and ready to be shown to the user
 - Failure: The data failed to load and an error is shown to the user
 */
public enum ListState<T> {
    case Loading
    case Loaded(data: [T])
    case Failure(error: ErrorType)

    var isLoading: Bool {
        switch self {
        case .Loading(_):
            return true
        default:
            return false
        }
    }

    var isError: Bool {
        switch self {
        case .Failure(_):
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

/**
 *  Protocol that any type that presents a list can conform to in order
 *  to customize how to represent the different states of a list
 */
public protocol ListStatePresenter: class {
    var loadingConfiguration: LoadingListConfiguration { get }
    var emptyConfiguration: EmptyListConfiguration { get }
    func errorConfiguration(forError error: ErrorType) -> ErrorListConfiguration
}

public extension ListStatePresenter {

    var loadingConfiguration: LoadingListConfiguration {
        let defaultConfig = LoadingListConfiguration.DefaultLoadingViewConfiguration()
        return LoadingListConfiguration.Default(defaultConfig)
    }

    var emptyConfiguration: EmptyListConfiguration {
        let defaultConfig = ActionableListConfiguration(
            title: NSAttributedString(string: "No Results"),
            message: nil,
            image: nil,
            buttonConfiguration: nil
        )
        return EmptyListConfiguration.Default(defaultConfig)
    }

}

public struct ActionableListConfiguration {
    public let title: NSAttributedString
    public let message: NSAttributedString?
    public let image: UIImage?
    public let buttonConfiguration: ButtonConfiguration?
    
    public init(title: NSAttributedString, message: NSAttributedString? = nil, image: UIImage? = nil, buttonConfiguration: ButtonConfiguration? = nil) {
        self.title = title
        self.message = message
        self.image = image
        self.buttonConfiguration = buttonConfiguration
    }
}

public enum LoadingListConfiguration {
    
    public struct DefaultLoadingViewConfiguration {
        let backgroundColor = UIColor.clearColor()
        let message: NSAttributedString? = nil
        let activityIndicatorStyle = UIActivityIndicatorViewStyle.Gray
    }
    
    case Default(DefaultLoadingViewConfiguration)
    case Custom(UIView)
}

public enum ErrorListConfiguration {
    case Default(ActionableListConfiguration)
    case Custom(UIView)
}

public enum EmptyListConfiguration {
    case Default(ActionableListConfiguration)
    case Custom(UIView)
}
