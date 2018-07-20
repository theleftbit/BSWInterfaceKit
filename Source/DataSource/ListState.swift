//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import BSWFoundation
import Deferred
import UIKit

/**
 Represents the different states that a list can be
 
 - Loading: The data is being remotely fetched.
 - Loaded:  The data is loaded and ready to be shown to the user
 - Failure: The data failed to load and an error is shown to the user
 */
public enum ListState<T> {
    case loading
    case loaded(data: [T])
    case failure(error: Error)

    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    public var isError: Bool {
        switch self {
        case .failure(_):
            return true
        default:
            return false
        }
    }

    public var isEmpty: Bool {
        switch self {
        case .loaded(let array):
            return array.count == 0
        default:
            return false
        }
    }
    
    public var data: [T]? {
        switch self {
        case .loaded(let array):
            return array
        default:
            return nil
        }
    }

    mutating func replaceData(forNewData newData: [T]) {
        switch self {
        case .loaded:
            self = .loaded(data: newData)
        default:
            break
        }
    }

    mutating func addingData(newData: [T]) {
        switch self {
        case .loaded(let data):
            self = .loaded(data: newData + data)
        default:
            break
        }
    }
}

extension ListState {
    public func mapListState<T>(_ result: Task<[T]>.Result) -> ListState<T> {
        switch result {
        case .success(let value):
            return .loaded(data: value)
        case .failure(let error):
            return .failure(error: error)
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
    func errorConfiguration(forError error: Error) -> ErrorListConfiguration
}

public extension ListStatePresenter {

    var loadingConfiguration: LoadingListConfiguration {
        let defaultConfig = LoadingListConfiguration.DefaultLoadingViewConfiguration()
        return LoadingListConfiguration.default(defaultConfig)
    }

    var emptyConfiguration: EmptyListConfiguration {
        let defaultConfig = ActionableListConfiguration(
            title: TextStyler.styler.attributedString("No Results")
        )
        return EmptyListConfiguration.default(defaultConfig)
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
    
    func viewRepresentation() -> UIView {
        return ErrorView(listConfig: self)
    }
}

public enum LoadingListConfiguration {
    
    public struct DefaultLoadingViewConfiguration {
        let backgroundColor = UIColor.clear
        let message: NSAttributedString? = nil
        let activityIndicatorStyle = UIActivityIndicatorView.Style.gray
    }
    
    case `default`(DefaultLoadingViewConfiguration)
    case custom(UIView)
}

public enum ErrorListConfiguration {
    case `default`(ActionableListConfiguration)
    case custom(UIView)
}

public enum EmptyListConfiguration {
    case `default`(ActionableListConfiguration)
    case custom(UIView)
}
