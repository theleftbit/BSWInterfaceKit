
import Foundation

extension String {
    var localized: String {
        LocalizationService.localized(self)
    }
}

public enum LocalizationService {
    /// Default localization hook used by InterfaceKit strings.
    ///
    /// On Apple platforms, looking up strings from `Bundle.main` works because the
    /// host app owns the main bundle and ships its localized resources there.
    /// Other runtimes do not necessarily have an equivalent app bundle lookup.
    /// Android/Skip apps, in particular, should inject this closure from the host
    /// app so strings are resolved through the app localization system, resources,
    /// or any runtime translation provider.
    public static nonisolated(unsafe) var localized: (String) -> String = {
        NSLocalizedString($0, bundle: .main, comment: "")
    }
}
