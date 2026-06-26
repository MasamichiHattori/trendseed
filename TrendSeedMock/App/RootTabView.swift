import SwiftUI

struct RootTabView: View {
    @StateObject private var videoFeedViewModel = VideoFeedViewModel()
    @StateObject private var purchaseManager = PurchaseManager()
    @StateObject private var interstitialAdManager = InterstitialAdManager()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    videos: videoFeedViewModel.videos,
                    isLoading: videoFeedViewModel.isLoading,
                    errorMessage: videoFeedViewModel.errorMessage,
                    onRetry: {
                        await videoFeedViewModel.refresh()
                    }
                )
            }
            .environmentObject(videoFeedViewModel)
            .environmentObject(purchaseManager)
            .environmentObject(interstitialAdManager)
            .tabItem {
                Label("ホーム", systemImage: "house")
            }

            NavigationStack {
                FavoritesView(favorites: videoFeedViewModel.favoriteVideos)
            }
            .environmentObject(videoFeedViewModel)
            .environmentObject(purchaseManager)
            .environmentObject(interstitialAdManager)
            .tabItem {
                Label("お気に入り", systemImage: "heart")
            }

            NavigationStack {
                PlanView()
            }
            .environmentObject(videoFeedViewModel)
            .environmentObject(purchaseManager)
            .environmentObject(interstitialAdManager)
            .tabItem {
                Label("プラン", systemImage: "sparkles.rectangle.stack")
            }
        }
        .tint(AppTheme.accent)
        .task {
            await videoFeedViewModel.loadVideosIfNeeded()
            await purchaseManager.prepare()
            interstitialAdManager.preloadIfNeeded()
        }
    }
}

#Preview {
    RootTabView()
}
