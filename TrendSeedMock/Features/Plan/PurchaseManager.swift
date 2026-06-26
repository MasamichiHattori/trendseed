import Foundation
import StoreKit
import OSLog

@MainActor
final class PurchaseManager: ObservableObject {
    enum PurchaseError: LocalizedError {
        case missingProductIdentifier
        case productUnavailable(productID: String, detail: String?)
        case purchaseCancelled
        case purchasePending
        case restoreNotFound
        case verificationFailed

        var errorDescription: String? {
            switch self {
            case .missingProductIdentifier:
                return "プレミアム商品の設定が見つかりません。"
            case .productUnavailable(let productID, let detail):
                let detailText = detail?.isEmpty == false ? "\n詳細: \(detail!)" : ""
                return "購入対象の商品情報を取得できませんでした。\nProduct ID: \(productID)\(detailText)"
            case .purchaseCancelled:
                return "購入はキャンセルされました。"
            case .purchasePending:
                return "購入処理は保留中です。承認後に反映されます。"
            case .restoreNotFound:
                return "復元できる購入が見つかりませんでした。"
            case .verificationFailed:
                return "購入情報の確認に失敗しました。"
            }
        }
    }

    @Published private(set) var premiumProduct: Product?
    @Published private(set) var isPremium = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published private(set) var hasPrepared = false
    @Published private(set) var lastStoreKitDiagnostic: String?

    private var updatesTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "com.trendseed.mobile", category: "PurchaseManager")

    deinit {
        updatesTask?.cancel()
    }

    func prepare() async {
        if updatesTask == nil {
            updatesTask = observeTransactionUpdates()
        }

        await loadProducts()
        await refreshPremiumStatus()
        hasPrepared = true
    }

    var shouldShowAds: Bool {
        !isPremium
    }

    func purchasePremium() async throws {
        guard !isPurchasing else { return }
        guard !AppConfig.premiumProductID.isEmpty else {
            throw PurchaseError.missingProductIdentifier
        }

        if premiumProduct == nil {
            await loadProducts()
        }

        guard let premiumProduct else {
            throw PurchaseError.productUnavailable(
                productID: AppConfig.premiumProductID,
                detail: lastStoreKitDiagnostic
            )
        }

        isPurchasing = true
        defer { isPurchasing = false }

        let result = try await premiumProduct.purchase()
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await transaction.finish()
            await refreshPremiumStatus()
        case .userCancelled:
            throw PurchaseError.purchaseCancelled
        case .pending:
            throw PurchaseError.purchasePending
        @unknown default:
            throw PurchaseError.verificationFailed
        }
    }

    func restorePurchases() async throws -> Bool {
        guard !isRestoring else { return isPremium }

        isRestoring = true
        defer { isRestoring = false }

        try await AppStore.sync()
        let hadPremium = isPremium
        await refreshPremiumStatus()

        if !isPremium && !hadPremium {
            throw PurchaseError.restoreNotFound
        }

        return isPremium
    }

    private func loadProducts() async {
        guard !AppConfig.premiumProductID.isEmpty else {
            premiumProduct = nil
            lastStoreKitDiagnostic = "PREMIUM_PRODUCT_ID が空です。"
            return
        }

        do {
            let productIDs = [AppConfig.premiumProductID]
            let products = try await Product.products(for: productIDs)
            premiumProduct = products.first

            if let premiumProduct {
                lastStoreKitDiagnostic = """
                Product.products(for:) 成功
                requested: \(productIDs.joined(separator: ", "))
                count: \(products.count)
                first: \(premiumProduct.id)
                """
                logger.info("StoreKit product fetch succeeded. requested=\(productIDs.joined(separator: ", "), privacy: .public) count=\(products.count, privacy: .public) first=\(premiumProduct.id, privacy: .public)")
            } else {
                lastStoreKitDiagnostic = """
                Product.products(for:) は成功しましたが、商品が0件でした。
                requested: \(productIDs.joined(separator: ", "))
                """
                logger.error("StoreKit product fetch returned 0 products. requested=\(productIDs.joined(separator: ", "), privacy: .public)")
            }
        } catch {
            premiumProduct = nil
            lastStoreKitDiagnostic = """
            Product.products(for:) で例外が発生しました。
            requested: \(AppConfig.premiumProductID)
            error: \(String(describing: error))
            """
            logger.error("StoreKit product fetch failed. requested=\(AppConfig.premiumProductID, privacy: .public) error=\(String(describing: error), privacy: .public)")
        }
    }

    private func refreshPremiumStatus() async {
        var hasActivePremium = false

        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else {
                continue
            }

            guard transaction.productID == AppConfig.premiumProductID else {
                continue
            }

            if transaction.revocationDate == nil {
                hasActivePremium = true
            }
        }

        isPremium = hasActivePremium
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await update in Transaction.updates {
                guard let transaction = try? self.checkVerified(update) else {
                    continue
                }

                await transaction.finish()
                await self.refreshPremiumStatus()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}
