import Observation
import SwiftUI

extension PurchaseOutcome {
    /// 購入できなかったときの文言（キャンセルは何も出さない）
    var message: LocalizedStringKey? {
        switch self {
        case .pending: "承認されると使えるようになります。"
        case .failed: "購入できませんでした。もう一度お試しください。"
        case .purchased, .cancelled: nil
        }
    }
}

@Observable
final class FilmLoadModel {
    var selected: CameraID
    let isMidRoll: Bool
    let purchases: any PurchaseProviding
    private(set) var isBuying = false
    private(set) var message: LocalizedStringKey?

    init(selected: CameraID, isMidRoll: Bool, purchases: any PurchaseProviding) {
        self.selected = selected
        self.isMidRoll = isMidRoll
        self.purchases = purchases
    }

    var isSelectedUsable: Bool { purchases.isUsable(selected) }
    /// 4台セットは1台も買っていないときだけ出す
    var showsBundle: Bool { !purchases.hasAnyPurchase }

    func select(_ camera: CameraID) {
        selected = camera
        message = nil
    }

    /// 買えたら true
    func buyBundle() async -> Bool {
        guard !isBuying else { return false }
        isBuying = true
        message = nil
        defer { isBuying = false }
        let outcome = await purchases.purchase(.bundle)
        message = outcome.message
        return outcome == .purchased
    }
}
