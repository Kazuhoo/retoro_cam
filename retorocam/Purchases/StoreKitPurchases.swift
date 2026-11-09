import Foundation
import Observation
import StoreKit
import os

/// StoreKit 2 による購入。検証済みの取引だけを信用する。
@Observable
final class StoreKitPurchases: PurchaseProviding {
    private(set) var ownedItems: Set<StoreItem> = []
    private(set) var isLoadingPrices = false

    private var products: [String: Product] = [:]
    @ObservationIgnored private var updates: Task<Void, Never>?
    private static let logger = Logger(subsystem: "retorocam", category: "Purchases")

    init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refreshOwned()
            }
        }
        Task { await refreshOwned() }
    }

    func displayPrice(for item: StoreItem) -> String? {
        products[item.productID]?.displayPrice
    }

    func loadPrices() async {
        guard products.isEmpty, !isLoadingPrices else { return }
        isLoadingPrices = true
        defer { isLoadingPrices = false }
        do {
            let loaded = try await Product.products(for: StoreItem.all.map(\.productID))
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch {
            Self.logger.error("価格を取得できません: \(error.localizedDescription, privacy: .public)")
        }
    }

    func purchase(_ item: StoreItem) async -> PurchaseOutcome {
        guard let product = products[item.productID] else { return .failed }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshOwned()
                return .purchased
            case .success(.unverified):
                return .failed
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed
            }
        } catch {
            Self.logger.error("購入に失敗しました: \(error.localizedDescription, privacy: .public)")
            return .failed
        }
    }

    func restore() async -> Bool {
        do {
            try await AppStore.sync()
            await refreshOwned()
            return true
        } catch {
            Self.logger.error("復元に失敗しました: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// 返金された商品も外れるよう、毎回作り直す
    private func refreshOwned() async {
        var owned: Set<StoreItem> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result, transaction.revocationDate == nil,
                  let item = StoreItem.all.first(where: { $0.productID == transaction.productID })
            else { continue }
            owned.insert(item)
        }
        ownedItems = owned
    }
}
