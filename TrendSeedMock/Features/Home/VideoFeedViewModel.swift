import Foundation

@MainActor
final class VideoFeedViewModel: ObservableObject {
    @Published private(set) var videos: [TrendVideo] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?
    @Published private var favoriteVideoIDs: Set<String> = []

    private let service: SupabaseVideoService
    private var hasLoaded = false

    init(service: SupabaseVideoService = SupabaseVideoService()) {
        self.service = service
    }

    var favoriteVideos: [TrendVideo] {
        videos.filter { favoriteVideoIDs.contains($0.id) }
    }

    func isFavorite(_ video: TrendVideo) -> Bool {
        favoriteVideoIDs.contains(video.id)
    }

    func toggleFavorite(_ video: TrendVideo) {
        if favoriteVideoIDs.contains(video.id) {
            favoriteVideoIDs.remove(video.id)
        } else {
            favoriteVideoIDs.insert(video.id)
        }
    }

    func loadVideosIfNeeded() async {
        guard !hasLoaded else { return }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedVideos = try await service.fetchViralPosts()
            videos = fetchedVideos
            errorMessage = nil
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
            hasLoaded = true
        }
    }
}
