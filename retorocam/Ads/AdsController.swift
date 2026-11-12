import Foundation
import GoogleMobileAds
import Observation

/// このセッションで広告を出すかを決める
@Observable
final class AdsController {
    enum Session {
        /// まだ判断していない（初回起動のセッションはこのまま）
        case undecided
        /// 起動時に購入済みだったので、広告を出さない
        case noAds
        /// 同意の流れの途中。枠の場所だけ空ける
        case preparing
        case ready
    }

    private(set) var session = Session.undecided
    private(set) var isPrivacyOptionsRequired = false

    private let settings: AppSettings
    private let purchases: any PurchaseProviding
    private let consent = AdConsentCoordinator()
    @ObservationIgnored private var hasStarted = false

    init(settings: AppSettings, purchases: any PurchaseProviding) {
        self.settings = settings
        self.purchases = purchases
    }

    /// 広告枠を置くか。買った瞬間に消える
    var showsSlot: Bool {
        (session == .preparing || session == .ready) && !purchases.hasAnyPurchase
    }

    var isReady: Bool { session == .ready }

    static var bannerUnitID: String { infoValue("GADBannerUnitID") }

    private static func infoValue(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }

    /// 2回目以降の起動で、オンボーディングの完了後に1度だけ実行する
    func startIfNeeded() async {
        guard !hasStarted, settings.launchCount >= 2, settings.hasSeenOnboarding else { return }
        hasStarted = true

        await purchases.waitForOwnership()
        // ID がないまま SDK を開始するとアプリが落ちる
        guard !purchases.hasAnyPurchase, !Self.infoValue("GADApplicationIdentifier").isEmpty,
              !Self.bannerUnitID.isEmpty else {
            session = .noAds
            return
        }
        session = .preparing
        let result = await consent.gather()
        isPrivacyOptionsRequired = result.isPrivacyOptionsRequired
        guard result.canRequestAds else { return }
        _ = await MobileAds.shared.start()
        session = .ready
    }

    func presentPrivacyOptions() async {
        await consent.presentPrivacyOptions()
    }
}
