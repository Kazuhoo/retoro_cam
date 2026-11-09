import Observation
import SwiftUI

@Observable
final class SettingsModel {
    let purchases: any PurchaseProviding
    private(set) var isRestoring = false
    /// 購入の復元の結果
    private(set) var restoreMessage: LocalizedStringKey?

    init(purchases: any PurchaseProviding) {
        self.purchases = purchases
    }

    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    func restore() async {
        guard !isRestoring else { return }
        isRestoring = true
        restoreMessage = nil
        defer { isRestoring = false }
        if await purchases.restore() {
            restoreMessage = purchases.hasAnyPurchase ? "購入を復元しました。" : "復元できる購入はありませんでした。"
        } else {
            restoreMessage = "復元できませんでした。もう一度お試しください。"
        }
    }
}
