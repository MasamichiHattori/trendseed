import Foundation

@MainActor
final class VideoOpenAdCoordinator: ObservableObject {
    struct AdPresentation: Identifiable {
        let id = UUID()
    }

    @Published private(set) var activeAd: AdPresentation?
    @Published private(set) var isPresentingAd = false

    private var continuation: CheckedContinuation<Void, Never>?

    func showAdBeforeOpenVideo() async {
        guard !isPresentingAd else { return }

        await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.isPresentingAd = true

            guard prepareAdPresentation() else {
                completeAdPresentation()
                return
            }

            self.activeAd = AdPresentation()
        }
    }

    func completeAdPresentation() {
        activeAd = nil
        isPresentingAd = false

        continuation?.resume()
        continuation = nil
    }

    func handleDismissIfNeeded() {
        guard isPresentingAd else { return }
        completeAdPresentation()
    }

    private func prepareAdPresentation() -> Bool {
        true
    }
}
