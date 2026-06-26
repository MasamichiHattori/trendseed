import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("プレミアムで見放題")
                        .font(.largeTitle.bold())

                    Text("気になる海外トレンドを深掘りし、プロンプトまでそのまま活用できる想定のプラン画面です。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                planCard(
                    title: "無料プラン",
                    subtitle: "まずは軽く試したい方向け。分析結果の詳細を見る前に広告が表示されます",
                    features: MockData.freePlanFeatures,
                    accent: Color.gray.opacity(0.15),
                    textColor: .primary
                )

                planCard(
                    title: "プレミアムプラン",
                    subtitle: "分析もプロンプトもフル活用。分析結果の詳細前の広告なし",
                    price: "月額980円",
                    features: MockData.premiumPlanFeatures,
                    accent: AppTheme.accent.opacity(0.12),
                    textColor: .primary,
                    highlight: true
                )

                Button {
                    Task {
                        await purchasePremium()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if purchaseManager.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(purchaseManager.isPremium ? "プレミアム利用中" : "プレミアムを始める")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .disabled(purchaseManager.isPurchasing || purchaseManager.isRestoring || purchaseManager.isPremium)
                .opacity((purchaseManager.isPurchasing || purchaseManager.isRestoring || purchaseManager.isPremium) ? 0.75 : 1)
                .padding(.horizontal)
                .padding(.top, 8)

                Button {
                    Task {
                        await restorePurchases()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if purchaseManager.isRestoring {
                            ProgressView()
                                .controlSize(.small)
                        }

                        Text("購入を復元")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(purchaseManager.isPurchasing || purchaseManager.isRestoring)
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        NavigationLink("利用規約") {
                            LegalDocumentView(document: .terms)
                        }

                        NavigationLink("プライバシーポリシー") {
                            LegalDocumentView(document: .privacy)
                        }

                        NavigationLink("解約・お問い合わせ") {
                            SupportView()
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .background(AppTheme.grouped.ignoresSafeArea())
        .navigationTitle("プラン")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await purchaseManager.prepare()
        }
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private func planCard(
        title: String,
        subtitle: String,
        price: String? = nil,
        features: [PlanFeature],
        accent: Color,
        textColor: Color,
        highlight: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(textColor)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    if let price {
                        Text(price)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(highlight ? AppTheme.accent : textColor)
                            .padding(.top, 2)
                    }
                }

                Spacer()

                if highlight {
                    Text("おすすめ")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.accent.opacity(0.12), in: Capsule())
                }
            }

            ForEach(features) { feature in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(highlight ? AppTheme.accent : .secondary)

                    Text(feature.title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(accent)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(highlight ? AppTheme.accent.opacity(0.25) : Color.black.opacity(0.05), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private func purchasePremium() async {
        do {
            try await purchaseManager.purchasePremium()
            showAlert(
                title: "購入が完了しました",
                message: "プレミアムプランが利用できるようになりました。"
            )
        } catch {
            showAlert(
                title: "購入できませんでした",
                message: error.localizedDescription
            )
        }
    }

    private func restorePurchases() async {
        do {
            let restored = try await purchaseManager.restorePurchases()
            showAlert(
                title: restored ? "購入を復元しました" : "確認が必要です",
                message: restored
                    ? "以前の購入状態を反映しました。"
                    : "購入状態を確認できませんでした。"
            )
        } catch {
            showAlert(
                title: "復元できませんでした",
                message: error.localizedDescription
            )
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isShowingAlert = true
    }
}

#Preview {
    NavigationStack {
        PlanView()
            .environmentObject(PurchaseManager())
    }
}
