import SwiftUI
import UIKit

struct VideoDetailView: View {
    private enum AnalysisFocus: String, CaseIterable, Identifiable {
        case hook = "フック"
        case gap = "ギャップ"
        case retention = "維持"
        case reward = "報酬"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .hook: "sparkles.rectangle.stack"
            case .gap: "arrow.left.arrow.right.square"
            case .retention: "chart.line.uptrend.xyaxis"
            case .reward: "gift"
            }
        }

        var detailTitle: String {
            switch self {
            case .hook: "フック分析"
            case .gap: "ギャップ分析"
            case .retention: "維持分析"
            case .reward: "報酬分析"
            }
        }

        var caption: String {
            switch self {
            case .hook: "興味を引く"
            case .gap: "意外性で上げる"
            case .retention: "期待を高く保つ"
            case .reward: "満足で完結"
            }
        }
    }

    let video: TrendVideo
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var videoFeedViewModel: VideoFeedViewModel
    @State private var selectedFocus: AnalysisFocus = .hook
    @State private var didCopyPrompt = false

    private var isFavorite: Bool {
        videoFeedViewModel.isFavorite(video)
    }

    private var selectedDetailText: String {
        switch selectedFocus {
        case .hook:
            video.hookAnalysis
        case .gap:
            video.gapAnalysis
        case .retention:
            video.retentionAnalysis
        case .reward:
            video.rewardAnalysis
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RemoteThumbnailView(
                    imageURL: video.thumbnailURL,
                    fallbackColors: video.thumbnailColors,
                    cornerRadius: 28
                )
                    .frame(height: 250)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(video.category)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())

                            Text(video.sourceDetailText)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.white)
                        .padding(18)
                    }
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .font(.title2.bold())

                    Text("更新日 \(video.updatedAt)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    StatBadge(label: "再生数", value: video.viewsText)
                    StatBadge(label: "いいね", value: video.likesText)
                    StatBadge(label: "コメント", value: video.commentsText)
                    StatBadge(label: "カテゴリー", value: video.category)
                    StatBadge(label: "国", value: video.countryCode)
                    StatBadge(label: "ソース", value: video.sourceName)
                }
                .padding(.horizontal)

                InsightSection(
                    title: "推奨理由",
                    bodyText: video.candidateReason
                )
                .padding(.horizontal)

                InsightSection(
                    title: "なぜ伸びているか",
                    bodyText: video.growthSummary,
                    emphasis: true
                )
                .padding(.horizontal)

                InsightSection(
                    title: "構造分析",
                    bodyText: video.structureAnalysis
                )
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 14) {
                    Text("分析フロー")
                        .font(.headline)
                        .padding(.horizontal)

                    analysisFlowView
                        .padding(.horizontal)

                    InsightSection(
                        title: selectedFocus.detailTitle,
                        bodyText: selectedDetailText,
                        emphasis: true
                    )
                    .padding(.horizontal)
                }

                PromptBlockView(prompt: video.prompt)
                    .padding(.horizontal)
                    .padding(.bottom, 120)
            }
            .padding(.top, 12)
        }
        .background(AppTheme.grouped.ignoresSafeArea())
        .navigationTitle("分析結果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    videoFeedViewModel.toggleFavorite(video)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? AppTheme.accent : .primary)
                }
            }
        }
        .alert("プロンプトをコピーしました", isPresented: $didCopyPrompt) {
            Button("OK", role: .cancel) {}
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    guard let sourceURL = video.sourceURL else { return }
                    openURL(sourceURL)
                } label: {
                    Text("YouTubeを見る")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(video.sourceURL == nil)
                .opacity(video.sourceURL == nil ? 0.55 : 1)

                Button {
                    UIPasteboard.general.string = video.prompt
                    didCopyPrompt = true
                } label: {
                    Text("プロンプトをコピー")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
    }

    private var analysisFlowView: some View {
        let points: [(x: CGFloat, y: CGFloat)] = [
            (0.08, 0.84),
            (0.33, 0.50),
            (0.66, 0.38),
            (0.90, 0.12)
        ]

        return VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let resolvedPoints = points.map { point in
                        CGPoint(x: width * point.x, y: height * point.y)
                    }

                    AnalysisAreaShape(points: resolvedPoints, baseline: height - 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.indigo.opacity(0.20),
                                    Color.indigo.opacity(0.04)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    AnalysisCurveShape(points: resolvedPoints)
                        .stroke(
                            Color.indigo.opacity(0.80),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )

                    ForEach(Array(AnalysisFocus.allCases.enumerated()), id: \.element) { index, focus in
                        let point = resolvedPoints[index]

                        Path { path in
                            path.move(to: CGPoint(x: point.x, y: point.y + 8))
                            path.addLine(to: CGPoint(x: point.x, y: height + 50))
                        }
                        .stroke(Color.indigo.opacity(0.16), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                        ZStack {
                            Circle()
                                .fill(selectedFocus == focus ? Color.indigo : .white)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    Circle()
                                        .stroke(Color.indigo.opacity(0.80), lineWidth: 2)
                                }

                            if focus == .reward {
                                Image(systemName: "star.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color.indigo)
                                    .offset(y: -18)
                            }
                        }
                        .position(point)
                    }
                }
            }
            .frame(height: 210)

            HStack(alignment: .top, spacing: 8) {
                ForEach(AnalysisFocus.allCases) { focus in
                    Button {
                        selectedFocus = focus
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: focus.icon)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(selectedFocus == focus ? Color.indigo : AppTheme.textSecondary)
                                .frame(width: 32, height: 32)

                            Text(focus.rawValue)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(focus.caption)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(selectedFocus == focus ? Color.indigo.opacity(0.08) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 12)
        .padding(.top, 18)
        .padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.elevated)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.indigo.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct AnalysisCurveShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        path.move(to: points[0])

        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let deltaX = (current.x - previous.x) / 2

            path.addCurve(
                to: current,
                control1: CGPoint(x: previous.x + deltaX, y: previous.y),
                control2: CGPoint(x: current.x - deltaX, y: current.y)
            )
        }

        return path
    }
}

private struct AnalysisAreaShape: Shape {
    let points: [CGPoint]
    let baseline: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = AnalysisCurveShape(points: points).path(in: rect)
        guard let first = points.first, let last = points.last else { return path }

        path.addLine(to: CGPoint(x: last.x, y: baseline))
        path.addLine(to: CGPoint(x: first.x, y: baseline))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: MockData.videos[0])
            .environmentObject(VideoFeedViewModel())
    }
}
