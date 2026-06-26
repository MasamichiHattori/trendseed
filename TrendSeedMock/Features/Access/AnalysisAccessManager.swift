import Foundation

@MainActor
final class AnalysisAccessManager: ObservableObject {
    private enum StorageKeys {
        static let lastViewedDate = "analysisAccess.lastViewedDate"
        static let viewedAnalysisIDs = "analysisAccess.viewedAnalysisIDs"
    }

    private let userDefaults: UserDefaults
    private let calendar: Calendar
    private let dailyFreeLimit: Int

    @Published private(set) var viewedAnalysisIDsToday: [String] = []
    @Published private(set) var currentDateKey: String

    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        dailyFreeLimit: Int = 1
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.dailyFreeLimit = dailyFreeLimit
        self.currentDateKey = Self.dateKey(for: Date(), calendar: calendar)

        loadStoredState()
        refreshIfNeeded()
    }

    var remainingFreeViewsToday: Int {
        max(0, dailyFreeLimit - viewedAnalysisIDsToday.count)
    }

    func canOpenAnalysisResult(id: String, on date: Date = Date()) -> Bool {
        refreshIfNeeded(now: date)

        if viewedAnalysisIDsToday.contains(id) {
            return true
        }

        return viewedAnalysisIDsToday.count < dailyFreeLimit
    }

    func recordAnalysisResultView(id: String, on date: Date = Date()) {
        refreshIfNeeded(now: date)

        guard !viewedAnalysisIDsToday.contains(id) else { return }
        guard viewedAnalysisIDsToday.count < dailyFreeLimit else { return }

        viewedAnalysisIDsToday.append(id)
        persist()
    }

    func refreshIfNeeded(now: Date = Date()) {
        let todayKey = Self.dateKey(for: now, calendar: calendar)
        guard todayKey != currentDateKey else { return }

        currentDateKey = todayKey
        viewedAnalysisIDsToday = []
        persist()
    }

    private func loadStoredState() {
        let storedDateKey = userDefaults.string(forKey: StorageKeys.lastViewedDate)
        currentDateKey = storedDateKey ?? currentDateKey
        viewedAnalysisIDsToday = userDefaults.stringArray(forKey: StorageKeys.viewedAnalysisIDs) ?? []
    }

    private func persist() {
        userDefaults.set(currentDateKey, forKey: StorageKeys.lastViewedDate)
        userDefaults.set(viewedAnalysisIDsToday, forKey: StorageKeys.viewedAnalysisIDs)
    }

    private static func dateKey(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
