import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var interstitialAdManager: InterstitialAdManager

    enum SortOption: String, CaseIterable, Identifiable {
        case trend = "トレンド順"
        case views = "再生数順"
        case updated = "更新日順"

        var id: String { rawValue }
    }

    let videos: [TrendVideo]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: (() async -> Void)?

    @State private var searchText = ""
    @State private var selectedCategory = "すべて"
    @State private var selectedSort: SortOption = .trend
    @State private var selectedVideo: TrendVideo?
    @State private var isOpeningVideo = false
    @State private var limitAlertMessage = ""
    @State private var isShowingLimitAlert = false
    @StateObject private var analysisAccessManager = AnalysisAccessManager()

    private let listSpacing: CGFloat = 14
    private var isInitialLoading: Bool {
        isLoading && videos.isEmpty
    }

    private var filteredVideos: [TrendVideo] {
        let categoryFiltered = videos.filter { video in
            selectedCategory == "すべて" || video.category == selectedCategory
        }

        let searchFiltered = categoryFiltered.filter { video in
            searchText.isEmpty ||
            video.title.localizedCaseInsensitiveContains(searchText) ||
            video.channelName.localizedCaseInsensitiveContains(searchText) ||
            video.category.localizedCaseInsensitiveContains(searchText)
        }

        switch selectedSort {
        case .trend:
            return searchFiltered.sorted { $0.trendSortTimestamp > $1.trendSortTimestamp }
        case .views:
            return searchFiltered.sorted { $0.numericViewCount > $1.numericViewCount }
        case .updated:
            return searchFiltered.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 16

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("海外トレンド一覧")
                            .font(.largeTitle.bold())

                        Text("伸びた理由と日本向けの置き換え案を、一覧からすばやく確認できます。")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    FilterChipRow(
                        categories: MockData.categories,
                        selectedCategory: $selectedCategory
                    )

                    HStack {
                        Text("\(filteredVideos.count)件")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)

                        Spacer()

                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        }

                        Menu {
                            Picker("ソート", selection: $selectedSort) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Label(selectedSort.rawValue, systemImage: "arrow.up.arrow.down.circle")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.surface, in: Capsule())
                        }
                    }
                    .padding(.horizontal)

                    if isInitialLoading {
                        VStack(spacing: 14) {
                            ProgressView()
                                .controlSize(.regular)

                            Text("トレンドを読み込み中...")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                        .padding(.horizontal)
                    } else {
                        if let errorMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "wifi.exclamationmark")
                                    .foregroundStyle(AppTheme.accent)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Supabase接続を確認してください")
                                        .font(.subheadline.weight(.semibold))

                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                if let onRetry {
                                    Button("再読み込み") {
                                        Task {
                                            await onRetry()
                                        }
                                    }
                                    .font(.caption.weight(.semibold))
                                }
                            }

                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(AppTheme.elevated)
                            )
                            .padding(.horizontal)
                        }

                        LazyVStack(spacing: listSpacing) {
                            ForEach(filteredVideos) { video in
                                Button {
                                    Task {
                                        await handleVideoSelection(video)
                                    }
                                } label: {
                                    VideoCardView(video: video)
                                }
                                .buttonStyle(.plain)
                                .disabled(isOpeningVideo || interstitialAdManager.isShowingAd)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(AppTheme.grouped.ignoresSafeArea())
        .navigationTitle("ホーム")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "動画を検索")
        .navigationDestination(item: $selectedVideo) { video in
            VideoDetailView(video: video)
        }
        .alert("無料プランの上限です", isPresented: $isShowingLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(limitAlertMessage)
        }
    }

    private func handleVideoSelection(_ video: TrendVideo) async {
        guard !isOpeningVideo else { return }
        isOpeningVideo = true
        defer { isOpeningVideo = false }

        if !purchaseManager.hasPrepared {
            await purchaseManager.prepare()
        }

        analysisAccessManager.refreshIfNeeded()

        if purchaseManager.isPremium {
            selectedVideo = video
            return
        }

        guard analysisAccessManager.canOpenAnalysisResult(id: video.analysisResultID) else {
            limitAlertMessage = "無料プランでは、分析結果の詳細閲覧は1日1件までです。続けて見るにはプレミアムプランをご利用ください。"
            isShowingLimitAlert = true
            return
        }

        if purchaseManager.shouldShowAds {
            await interstitialAdManager.showAdBeforeOpenVideo()
        }

        analysisAccessManager.recordAnalysisResultView(id: video.analysisResultID)
        interstitialAdManager.preloadIfNeeded()
        selectedVideo = video
    }
}

#Preview {
    NavigationStack {
        HomeView(
            videos: MockData.videos,
            isLoading: false,
            errorMessage: nil,
            onRetry: nil
        )
    }
}
