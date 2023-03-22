import StoreKit

final class AppRatingManager {
    // MARK: Internal

    func openRatePage() {
        let appId = 1636862100
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") {
            NSWorkspace.shared.open(url)
        }
    }

    func requestRateIfNeeded() {
        requestCount += 1

        guard
            requestCount > 2,
            requestCount % 3 == 0
        else {
            return
        }
        SKStoreReviewController.requestReview()
    }

    // MARK: Private

    @UserDefault("rate_request_count") private var requestCount = 0
}
