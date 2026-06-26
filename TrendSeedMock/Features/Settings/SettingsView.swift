import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false

    var body: some View {
        List {
            Section("利用情報") {
                LabeledContent("プラン名", value: purchaseManager.isPremium ? "プレミアムプラン" : "無料プラン")
            }

            Section("規約・ポリシー") {
                NavigationLink("利用規約") {
                    LegalDocumentView(document: .terms)
                }

                NavigationLink("プライバシーポリシー") {
                    LegalDocumentView(document: .privacy)
                }
            }

            Section("サポート") {
                NavigationLink("解約・お問い合わせ") {
                    SupportView()
                }

                Button {
                    Task {
                        await restorePurchases()
                    }
                } label: {
                    HStack {
                        Text("購入を復元")

                        Spacer()

                        if purchaseManager.isRestoring {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }
                .disabled(purchaseManager.isPurchasing || purchaseManager.isRestoring)
            }
        }
        .navigationTitle("設定")
        .task {
            await purchaseManager.prepare()
        }
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func restorePurchases() async {
        do {
            let restored = try await purchaseManager.restorePurchases()
            alertTitle = restored ? "購入を復元しました" : "確認が必要です"
            alertMessage = restored
                ? "以前の購入状態を反映しました。"
                : "購入状態を確認できませんでした。"
        } catch {
            alertTitle = "復元できませんでした"
            alertMessage = error.localizedDescription
        }

        isShowingAlert = true
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(PurchaseManager())
    }
}
