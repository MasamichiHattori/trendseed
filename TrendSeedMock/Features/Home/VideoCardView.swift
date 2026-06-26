import SwiftUI

struct VideoCardView: View {
    let video: TrendVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteThumbnailView(
                imageURL: video.thumbnailURL,
                fallbackColors: video.thumbnailColors,
                cornerRadius: 20
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

            Text(video.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(video.sourceDetailText)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("再生数 \(video.viewsText)")
                Text("いいね \(video.likesText)")
                Text("更新日 \(video.updatedAt)")
            }
            .font(.caption)
            .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.elevated)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.015), radius: 4, y: 2)
    }
}
