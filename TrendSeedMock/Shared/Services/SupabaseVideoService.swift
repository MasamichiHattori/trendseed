import Foundation
import SwiftUI

struct SupabaseVideoService {
    enum ServiceError: LocalizedError {
        case missingConfiguration
        case invalidKeyType
        case invalidURL
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .missingConfiguration:
                "Supabaseの設定が見つかりません。Secrets.xcconfig を確認してください。"
            case .invalidKeyType:
                "iOSアプリには anon public key を設定してください。secret key は使えません。"
            case .invalidURL:
                "SupabaseのURLが正しくありません。"
            case .invalidResponse:
                "Supabaseから正しいレスポンスを取得できませんでした。"
            }
        }
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }

    func fetchViralPosts() async throws -> [TrendVideo] {
        guard !AppConfig.isUsingSecretKey else {
            throw ServiceError.invalidKeyType
        }

        guard AppConfig.hasSupabaseCredentials else {
            throw ServiceError.missingConfiguration
        }

        guard var components = URLComponents(string: "\(AppConfig.supabaseURLString)/rest/v1/viral_posts") else {
            throw ServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name: "select",
                value: "title,created_at,original_published_at,view_count,like_count,comment_count,channel_name,category,country,source_platform,source_url,thumbnail_url,candidate_reason,why_trending,structure_analysis,hook_analysis,gap,retention_factor,reward,idea_prompt_full"
            ),
            URLQueryItem(name: "status", value: "eq.published"),
            URLQueryItem(name: "order", value: "created_at.desc")
        ]

        guard let url = components.url else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(AppConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(AppConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw ServiceError.invalidResponse
        }

        let posts = try decoder.decode([ViralPostDTO].self, from: data)
        return posts.map { $0.toTrendVideo() }
    }
}

private struct ViralPostDTO: Decodable {
    let title: String?
    let createdAt: String?
    let originalPublishedAt: String?
    let viewCount: Int64?
    let likeCount: Int64?
    let commentCount: Int64?
    let channelName: String?
    let category: String?
    let country: String?
    let sourcePlatform: String?
    let sourceURL: String?
    let thumbnailURL: String?
    let candidateReason: String?
    let whyTrending: String?
    let structureAnalysis: String?
    let hookAnalysis: String?
    let gap: String?
    let retentionFactor: String?
    let reward: String?
    let ideaPromptFull: String?

    enum CodingKeys: String, CodingKey {
        case title
        case createdAt = "created_at"
        case originalPublishedAt = "original_published_at"
        case viewCount = "view_count"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case channelName = "channel_name"
        case category
        case country
        case sourcePlatform = "source_platform"
        case sourceURL = "source_url"
        case thumbnailURL = "thumbnail_url"
        case candidateReason = "candidate_reason"
        case whyTrending = "why_trending"
        case structureAnalysis = "structure_analysis"
        case hookAnalysis = "hook_analysis"
        case gap
        case retentionFactor = "retention_factor"
        case reward
        case ideaPromptFull = "idea_prompt_full"
    }

    func toTrendVideo() -> TrendVideo {
        let resolvedCategory = LocalizedCategoryMapper.displayName(for: category ?? "")
        let resolvedCountry = (country ?? "").uppercased()
        let resolvedSource = sourcePlatform ?? ""

        return TrendVideo(
            id: [title ?? "", originalPublishedAt ?? ""].joined(separator: "::").isEmpty ? UUID().uuidString : [title ?? "", originalPublishedAt ?? ""].joined(separator: "::"),
            title: title ?? "タイトル未設定",
            category: resolvedCategory.isEmpty ? "未分類" : resolvedCategory,
            countryCode: resolvedCountry.isEmpty ? "-" : resolvedCountry,
            sourceName: resolvedSource.isEmpty ? "-" : resolvedSource,
            sourceURLString: sanitized(sourceURL, fallback: ""),
            thumbnailURLString: sanitized(thumbnailURL, fallback: ""),
            channelName: sanitized(channelName, fallback: [resolvedCountry, resolvedSource].filter { !$0.isEmpty }.joined(separator: " / ")),
            viewsText: CountFormatter.jpShortString(for: viewCount),
            likesText: CountFormatter.jpShortString(for: likeCount),
            commentsText: CountFormatter.jpShortString(for: commentCount),
            updatedAt: DateFormatter.displayDateString(from: originalPublishedAt),
            thumbnailColors: ThumbnailPalette.colors(for: resolvedCategory),
            candidateReason: sanitized(candidateReason, fallback: "推奨理由はまだありません。"),
            growthSummary: sanitized(whyTrending, fallback: "分析結果はまだありません。"),
            structureAnalysis: sanitized(structureAnalysis, fallback: "構造分析はまだありません。"),
            hookAnalysis: sanitized(hookAnalysis, fallback: "フック分析はまだありません。"),
            gapAnalysis: sanitized(gap, fallback: "ギャップ分析はまだありません。"),
            rewardAnalysis: sanitized(reward, fallback: "報酬分析はまだありません。"),
            retentionAnalysis: sanitized(retentionFactor, fallback: "維持分析はまだありません。"),
            languageDependency: .medium,
            prompt: sanitized(ideaPromptFull, fallback: "プロンプトはまだありません。"),
            trendSortTimestamp: DateFormatter.sortTimestamp(from: createdAt ?? originalPublishedAt)
        )
    }

    private func sanitized(_ value: String?, fallback: String) -> String {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? fallback : trimmed
    }
}

private enum LocalizedCategoryMapper {
    static func displayName(for value: String) -> String {
        switch value.lowercased() {
        case "all":
            "すべて"
        case "ai":
            "AI"
        case "food":
            "料理"
        case "fitness":
            "フィットネス"
        case "lifehack", "life_hack", "life hack":
            "ライフハック"
        case "beauty":
            "美容"
        case "business":
            "ビジネス"
        case "education":
            "教育"
        case "entertainment":
            "エンタメ"
        case "":
            ""
        default:
            value
        }
    }
}

private enum ThumbnailPalette {
    static func colors(for category: String) -> [Color] {
        switch category {
        case "AI":
            [.blue, .cyan]
        case "料理":
            [.orange, .yellow]
        case "フィットネス":
            [.mint, .green]
        case "美容":
            [.pink, .purple]
        case "ビジネス":
            [.indigo, .purple]
        case "教育":
            [.teal, .blue]
        case "エンタメ":
            [.red, .orange]
        default:
            [.gray, .blue.opacity(0.7)]
        }
    }
}

private enum CountFormatter {
    static func jpShortString(for value: Int64?) -> String {
        guard let value else { return "-" }

        if value >= 100_000_000 {
            return format(Double(value) / 100_000_000, suffix: "億")
        }

        if value >= 10_000 {
            return format(Double(value) / 10_000, suffix: "万")
        }

        return NumberFormatter.grouped.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static func format(_ value: Double, suffix: String) -> String {
        let number = value >= 100 ? value.rounded() : (value * 10).rounded() / 10
        let string = number.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(number))
            : String(number)
        return string + suffix
    }
}

private extension DateFormatter {
    static let supabaseISO8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let supabaseISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static func displayDateString(from rawValue: String?) -> String {
        guard let rawValue, !rawValue.isEmpty else { return "-" }

        if let date = supabaseISO8601WithFractional.date(from: rawValue) ?? supabaseISO8601.date(from: rawValue) {
            return displayDate.string(from: date)
        }

        if rawValue.count >= 10 {
            let prefix = String(rawValue.prefix(10)).replacingOccurrences(of: "-", with: ".")
            return prefix
        }

        return rawValue
    }

    static func sortTimestamp(from rawValue: String?) -> TimeInterval {
        guard let rawValue, !rawValue.isEmpty else { return 0 }

        if let date = supabaseISO8601WithFractional.date(from: rawValue) ?? supabaseISO8601.date(from: rawValue) {
            return date.timeIntervalSince1970
        }

        return 0
    }
}

private extension NumberFormatter {
    static let grouped: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
