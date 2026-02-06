import Foundation

/// Resolve locale-specific resource bundles for runtime language switching.
public enum LocalizationBundleResolver {
    /// Returns a localized bundle (`*.lproj`) for the provided locale if available.
    /// Falls back to the original bundle when no matching localization is found.
    public static func localizedBundle(for locale: Locale, in bundle: Bundle) -> Bundle {
        for identifier in candidateIdentifiers(for: locale) {
            if let path = bundle.path(forResource: identifier, ofType: "lproj"),
               let localizedBundle = Bundle(path: path) {
                return localizedBundle
            }
        }
        return bundle
    }
}

private extension LocalizationBundleResolver {
    static func candidateIdentifiers(for locale: Locale) -> [String] {
        var candidates: [String] = []

        let identifier = locale.identifier
        if !identifier.isEmpty {
            candidates.append(identifier)
            candidates.append(identifier.replacingOccurrences(of: "-", with: "_"))
            candidates.append(identifier.replacingOccurrences(of: "_", with: "-"))
        }

        if let languageCode = locale.language.languageCode?.identifier {
            candidates.append(languageCode)
        }

        if let languageCode = locale.languageCode {
            candidates.append(languageCode)
        }

        var unique: [String] = []
        unique.reserveCapacity(candidates.count)
        for candidate in candidates where !candidate.isEmpty && !unique.contains(candidate) {
            unique.append(candidate)
        }
        return unique
    }
}
