import Foundation
import GoogleMobileAds
import UIKit

@MainActor
final class InterstitialAdManager: NSObject, ObservableObject {
    private enum Constants {
        static let adUnitID = "ca-app-pub-6451159800764057/4640735545"
    }

    @Published private(set) var isLoading = false
    @Published private(set) var isShowingAd = false

    private var interstitialAd: InterstitialAd?
    private var showContinuation: CheckedContinuation<Void, Never>?

    func preloadIfNeeded() {
        guard interstitialAd == nil, !isLoading else { return }
        loadAd()
    }

    func showAdBeforeOpenVideo() async {
        guard !isShowingAd else { return }

        if interstitialAd == nil {
            preloadIfNeeded()
        }

        guard let rootViewController = Self.rootViewController else { return }
        guard let interstitialAd else { return }

        isShowingAd = true

        await withCheckedContinuation { continuation in
            showContinuation = continuation
            interstitialAd.present(from: rootViewController)
        }
    }

    private func loadAd() {
        isLoading = true

        InterstitialAd.load(with: Constants.adUnitID, request: Request()) { [weak self] ad, error in
            guard let self else { return }

            self.isLoading = false

            if let error {
                self.interstitialAd = nil
                print("AdMob interstitial load failed: \(error.localizedDescription)")
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    private func completePresentation() {
        isShowingAd = false

        let continuation = showContinuation
        showContinuation = nil
        continuation?.resume()
    }

    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        completePresentation()
        preloadIfNeeded()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        print("AdMob interstitial present failed: \(error.localizedDescription)")
        completePresentation()
        preloadIfNeeded()
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostViewController
        }

        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController ?? tabBarController
        }

        return self
    }
}
