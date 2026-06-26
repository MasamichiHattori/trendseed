import Foundation

enum AppConfig {
    static var supabaseURLString: String {
        resolvedValue(for: "SUPABASE_URL")
    }

    static var supabaseAnonKey: String {
        resolvedValue(for: "SUPABASE_ANON_KEY")
    }

    static var premiumProductID: String {
        resolvedValue(for: "PREMIUM_PRODUCT_ID")
    }

    static var supabaseURL: URL? {
        URL(string: supabaseURLString)
    }

    static var hasSupabaseCredentials: Bool {
        !supabaseURLString.isEmpty &&
        !supabaseAnonKey.isEmpty &&
        !supabaseURLString.contains("your-project-ref") &&
        !supabaseAnonKey.contains("your-anon-key") &&
        !supabaseAnonKey.hasPrefix("sb_secret_")
    }

    static var isUsingSecretKey: Bool {
        supabaseAnonKey.hasPrefix("sb_secret_")
    }

    private static func resolvedValue(for key: String) -> String {
        let runtimeValue = cleaned(runtimeSecretsValues[key] ?? "")
        if !runtimeValue.isEmpty {
            return runtimeValue
        }

        let infoValue = cleaned(Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "")
        if !infoValue.isEmpty {
            return infoValue
        }

        return cleaned(bundledXCConfigValues[key] ?? "")
    }

    private static func cleaned(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty || (trimmed.contains("$(") && trimmed.contains(")")) {
            return ""
        }

        return trimmed
    }

    private static var bundledXCConfigValues: [String: String] {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "xcconfig"),
            let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return [:]
        }

        return contents
            .split(whereSeparator: \.isNewline)
            .reduce(into: [:]) { result, rawLine in
                let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

                guard
                    !line.isEmpty,
                    !line.hasPrefix("//"),
                    let separatorIndex = line.firstIndex(of: "=")
                else {
                    return
                }

                let key = String(line[..<separatorIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(line[line.index(after: separatorIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                result[key] = value
            }
    }

    private static var runtimeSecretsValues: [String: String] {
        guard
            let url = Bundle.main.url(forResource: "RuntimeSecrets", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            return [:]
        }

        return json
    }
}
