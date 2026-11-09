import Observation

/// 購入画面へ渡す内容
struct PurchaseRequest {
    let item: StoreItem
    /// 購入済みで、袋の演出から始める（4台セット）
    let startsAtPack: Bool
    /// カメラを選ぶ画面で選んでいたカメラ
    let selected: CameraID
}

@Observable
final class AppRouter {
    enum Screen {
        case shooting, sendLab, darkroom
        case prints(Roll)
        case filmLoad(selected: CameraID)
        case purchase(PurchaseRequest)
        case settings
        /// isReplay は設定の「使い方を見る」から開いたとき
        case onboarding(isReplay: Bool)
    }

    var screen: Screen

    init(screen: Screen) {
        self.screen = screen
    }
}
