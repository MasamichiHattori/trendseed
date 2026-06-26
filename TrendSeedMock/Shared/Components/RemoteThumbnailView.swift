import SwiftUI

struct RemoteThumbnailView: View {
    let imageURL: URL?
    let fallbackColors: [Color]
    let cornerRadius: CGFloat

    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        placeholder
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .clipped()
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: fallbackColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
