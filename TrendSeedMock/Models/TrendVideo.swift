import SwiftUI

struct TrendVideo: Identifiable, Hashable {
    enum LanguageDependency: String, CaseIterable, Hashable {
        case high = "高"
        case medium = "中"
        case low = "低"

        var color: Color {
            switch self {
            case .high: .red
            case .medium: .orange
            case .low: .green
            }
        }
    }

    let id: String
    let title: String
    let category: String
    let countryCode: String
    let sourceName: String
    let sourceURLString: String
    let thumbnailURLString: String
    let channelName: String
    let viewsText: String
    let likesText: String
    let commentsText: String
    let updatedAt: String
    let thumbnailColors: [Color]
    let candidateReason: String
    let growthSummary: String
    let structureAnalysis: String
    let hookAnalysis: String
    let gapAnalysis: String
    let rewardAnalysis: String
    let retentionAnalysis: String
    let languageDependency: LanguageDependency
    let prompt: String
    let trendSortTimestamp: TimeInterval = 0

    var analysisResultID: String {
        id
    }

    var numericViewCount: Int {
        let normalized = viewsText.replacingOccurrences(of: ",", with: "")

        if normalized.hasSuffix("万"), let value = Double(normalized.dropLast()) {
            return Int(value * 10_000)
        }

        if normalized.hasSuffix("億"), let value = Double(normalized.dropLast()) {
            return Int(value * 100_000_000)
        }

        return Int(normalized) ?? 0
    }

    var sourceDetailText: String {
        if !channelName.isEmpty {
            return channelName
        }

        return [countryCode, sourceName]
            .filter { !$0.isEmpty }
            .joined(separator: " / ")
    }

    var sourceURL: URL? {
        guard !sourceURLString.isEmpty else { return nil }
        return URL(string: sourceURLString)
    }

    var thumbnailURL: URL? {
        guard !thumbnailURLString.isEmpty else { return nil }
        return URL(string: thumbnailURLString)
    }
}
