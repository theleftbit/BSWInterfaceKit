// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum BSWInterfaceKitStrings {
    /// Dismiss
    case Dismiss
    /// Yes
    case Yes
    /// No
    case No
    /// Do you want to delete this photo?
    case ConfirmDeleteTitle
    /// Add Photo
    case AddPhotoTitle
    /// Photo Album
    case PhotoAlbum
    /// Camera
    case Camera
}

extension BSWInterfaceKitStrings: CustomStringConvertible {
    var description: String { return self.string }
    
    var string: String {
        switch self {
        case .Dismiss:
            return BSWInterfaceKitStrings.tr("dismiss")
        case .Yes:
            return BSWInterfaceKitStrings.tr("yes")
        case .No:
            return BSWInterfaceKitStrings.tr("no")
        case .ConfirmDeleteTitle:
            return BSWInterfaceKitStrings.tr("confirm-delete-title")
        case .AddPhotoTitle:
            return BSWInterfaceKitStrings.tr("add-photo-title")
        case .PhotoAlbum:
            return BSWInterfaceKitStrings.tr("photo-album")
        case .Camera:
            return BSWInterfaceKitStrings.tr("camera")
        }
    }
    
    private static func tr(key: String, _ args: CVarArgType...) -> String {
        let format = NSLocalizedString(key, bundle: NSBundle.interfaceKitBundle(), comment: "")
        return String(format: format, locale: NSLocale.currentLocale(), arguments: args)
    }
}

internal func localizableString(key: BSWInterfaceKitStrings) -> String {
    return key.string
}