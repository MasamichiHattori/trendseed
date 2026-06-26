import SwiftUI

struct FavoritesView: View {
    let favorites: [TrendVideo]

    var body: some View {
        Group {
            if favorites.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("お気に入りがありません")
                        .font(.title3.bold())

                    Text("動画を保存して後から見返しましょう")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
                .background(AppTheme.grouped.ignoresSafeArea())
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(favorites) { video in
                            NavigationLink(value: video) {
                                VStack(alignment: .leading, spacing: 12) {
                                    RemoteThumbnailView(
                                        imageURL: video.thumbnailURL,
                                        fallbackColors: video.thumbnailColors,
                                        cornerRadius: 18
                                    )
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(16 / 9, contentMode: .fit)
                                    .overlay(alignment: .bottomLeading) {
                                        Text(video.category)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(.black.opacity(0.28), in: Capsule())
                                            .padding(12)
                                    }

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(video.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)

                                        Text(video.sourceDetailText)
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textSecondary)

                                        HStack(spacing: 12) {
                                            Text("再生数 \(video.viewsText)")
                                            Text("更新日 \(video.updatedAt)")
                                        }
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(AppTheme.elevated)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .background(AppTheme.grouped.ignoresSafeArea())
            }
        }
        .navigationTitle("お気に入り")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TrendVideo.self) { video in
            VideoDetailView(video: video)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(favorites: MockData.favoriteVideos)
            .environmentObject(VideoFeedViewModel())
    }
}
