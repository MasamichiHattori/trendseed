import SwiftUI

struct MockInterstitialAdView: View {
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 14) {
                    Text("広告")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.accent.opacity(0.12), in: Capsule())

                    Text("分析結果の詳細を見る前に広告を表示")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("将来的にはこの枠を Google AdMob のインタースティシャル広告に差し替える想定です。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.accent.opacity(0.22),
                                AppTheme.accent.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "play.rectangle.on.rectangle")
                                .font(.system(size: 42, weight: .semibold))
                                .foregroundStyle(AppTheme.accent)

                            Text("Mock Interstitial Ad")
                                .font(.headline)

                            Text("ここに広告クリエイティブが入ります")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }

                VStack(spacing: 12) {
                    Button("広告を見終えた") {
                        onClose()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Button("広告を閉じる") {
                        onClose()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.grouped.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                    }
                }
            }
        }
    }
}
