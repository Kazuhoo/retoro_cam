#if DEBUG
import Foundation

/// デバッグ欄の「有料の状態」を反映する（表示だけを変え、本物の購入記録には触らない）
final class DebugPurchases: PurchaseProviding {
    private let base: any PurchaseProviding
    private let settings = DebugSettings.shared

    init(base: any PurchaseProviding) {
        self.base = base
    }

    var ownedItems: Set<StoreItem> {
        switch settings.purchaseState {
        case .actual: base.ownedItems
        case .allOwned: Set(StoreItem.all)
        case .none: []
        }
    }

    var isLoadingPrices: Bool { base.isLoadingPrices }

    func displayPrice(for item: StoreItem) -> String? { base.displayPrice(for: item) }
    func loadPrices() async { await base.loadPrices() }
    func waitForOwnership() async { await base.waitForOwnership() }
    func purchase(_ item: StoreItem) async -> PurchaseOutcome { await base.purchase(item) }
    func restore() async -> Bool { await base.restore() }
}
#endif
