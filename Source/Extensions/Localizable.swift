// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum BSWInterfaceKitStrings {
    /// Dismiss
    case dismiss
    /// Yes
    case yes
    /// No
    case no
    /// Do you want to delete this photo?
    case confirmDeleteTitle
    /// Add Photo
    case addPhotoTitle
    /// Photo Album
    case photoAlbum
    /// Camera
    case camera
}

extension BSWInterfaceKitStrings: CustomStringConvertible {
    var description: String { return self.string }
    
    var string: String {
        switch self {
        case .dismiss:
            return BSWInterfaceKitStrings.tr("dismiss")
        case .yes:
            return BSWInterfaceKitStrings.tr("yes")
        case .no:
            return BSWInterfaceKitStrings.tr("no")
        case .confirmDeleteTitle:
            return BSWInterfaceKitStrings.tr("confirm-delete-title")
        case .addPhotoTitle:
            return BSWInterfaceKitStrings.tr("add-photo-title")
        case .photoAlbum:
            return BSWInterfaceKitStrings.tr("photo-album")
        case .camera:
            return BSWInterfaceKitStrings.tr("camera")
        }
    }
    
    fileprivate static func tr(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: Bundle.interfaceKitBundle(), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

internal func localizableString(_ key: BSWInterfaceKitStrings) -> String {
    return key.string
}

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: Bundle.interfaceKitBundle(), comment: "")
    }
}
