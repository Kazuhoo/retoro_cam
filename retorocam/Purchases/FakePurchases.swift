#if DEBUG
import Foundation
import Observation

/// シミュレータで画面を確認するための偽の購入（DEBUG のみ）。
/// RETORO_FAKE_PURCHASES に purchased / cancelled / pending / failed / noprice を渡すと有効になる。
/// RETORO_FAKE_OWNED には買ってあるカメラを「charcoal,pool」のように渡す。
@Observable
final class FakePurchases: PurchaseProviding {
    private(set) var ownedItems: Set<StoreItem>
    let isLoadingPrices = false
    private let mode: String

    init?(environment: [String: String] = ProcessInfo.processInfo.environment) {
        guard let mode = environment["RETORO_FAKE_PURCHASES"] else { return nil }
        self.mode = mode
        let owned = (environment["RETORO_FAKE_OWNED"] ?? "").split(separator: ",")
        ownedItems = Set(owned.compactMap { CameraID(rawValue: String($0)) }.map(StoreItem.camera))
    }

    func displayPrice(for item: StoreItem) -> String? {
        guard mode != "noprice" else { return nil }
        return item == .bundle ? "$2.99" : "$0.99"
    }

    func loadPrices() async {}

    func purchase(_ item: StoreItem) async -> PurchaseOutcome {
        switch mode {
        case "cancelled": return .cancelled
        case "pending": return .pending
        case "failed": return .failed
        default:
            ownedItems.insert(item)
            return .purchased
        }
    }

    func restore() async -> Bool { true }
}
#endif
