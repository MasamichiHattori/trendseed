import SwiftUI

struct SupportView: View {
    @Environment(\.openURL) private var openURL

    private let supportEmail = "support_trendseed@whai.jp"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                supportSection(
                    title: "解約方法",
                    body: "トレンドseedのサブスクリプションは、App Storeのアカウント設定から解約できます。"
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("解約手順")
                            .font(.headline)

                        stepText("1. iPhoneの「設定」アプリを開く")
                        stepText("2. 画面上部のApple IDをタップ")
                        stepText("3. 「サブスクリプション」をタップ")
                        stepText("4. 「トレンドseed」を選択")
                        stepText("5. 「サブスクリプションをキャンセルする」をタップ")

                        Text("アプリを削除しただけではサブスクリプションは解約されません。")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("解約後も、現在の請求期間が終了するまではプレミアム機能を利用できます。")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)

                        Button {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                openURL(url)
                            }
                        } label: {
                            Text("サブスクリプション管理を開く")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.top, 4)
                    }
                }

                supportSection(
                    title: "お問い合わせ",
                    body: "ご不明点や課金に関するお問い合わせは、以下のメールアドレスまでご連絡ください。"
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(supportEmail)
                            .font(.headline)

                        Text("問い合わせ時に含めてほしい情報")
                            .font(.headline)
                            .padding(.top, 4)

                        stepText("・利用中の端末")
                        stepText("・アプリのバージョン")
                        stepText("・問題が発生した日時")
                        stepText("・課金に関する問い合わせの場合は、購入状況の説明")

                        Button {
                            if let url = supportMailURL {
                                openURL(url)
                            }
                        } label: {
                            Text("メールで問い合わせ")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.grouped.ignoresSafeArea())
        .navigationTitle("解約・お問い合わせ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func supportSection<Content: View>(
        title: String,
        body: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.bold())

            Text(body)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(4)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.elevated)
        )
    }

    private func stepText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary)
    }

    private var supportMailURL: URL? {
        let subject = "トレンドseedへの問い合わせ"
        let body = """
        お問い合わせ内容：

        利用端末：
        アプリバージョン：\(appVersionText)
        発生日時：
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }

    private var appVersionText: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(shortVersion) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SupportView()
    }
}
