import SwiftUI

@main
struct TrendSeedMockApp: App {
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            if hasAcceptedTerms {
                RootTabView()
            } else {
                OnboardingView()
            }
        }
    }
}
