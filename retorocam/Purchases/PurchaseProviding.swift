import Foundation

enum PurchaseOutcome {
    case purchased, cancelled, pending, failed
}

/// 購入の窓口。画面はこのプロトコルだけを見る。
protocol PurchaseProviding: AnyObject {
    /// 買ってある商品
    var ownedItems: Set<StoreItem> { get }
    /// 価格を取得している最中か
    var isLoadingPrices: Bool { get }

    /// App Store から取得した、その地域の価格。取得できなければ nil
    func displayPrice(for item: StoreItem) -> String?
    /// 価格がまだなければ取得する
    func loadPrices() async
    func purchase(_ item: StoreItem) async -> PurchaseOutcome
    /// 成功したら true
    func restore() async -> Bool
}

extension PurchaseProviding {
    /// 何か1つでも購入済みか（広告の非表示に使う）
    var hasAnyPurchase: Bool { !ownedItems.isEmpty }

    /// そのカメラを使えるか
    func isUsable(_ camera: CameraID) -> Bool {
        camera.isFree || ownedItems.contains { $0.unlocks.contains(camera) }
    }
}
