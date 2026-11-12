import SwiftData

/// 画面をまたいで使うものをまとめる
struct AppServices {
    let clock: any Clock
    let rolls: RollStore
    let photos: PhotoStore
    let notifier: DeliveryNotifier
    let library: PhotoLibrarySaver
    let purchases: any PurchaseProviding
    let settings: AppSettings
    let ads: AdsController

    static func makeDefault(context: ModelContext) -> AppServices {
        #if DEBUG
        let clock: any Clock = DebugClock()
        #else
        let clock: any Clock = SystemClock()
        #endif
        let settings = AppSettings()
        let purchases = makePurchases()
        return AppServices(clock: clock, rolls: RollStore(context: context), photos: PhotoStore(),
                           notifier: DeliveryNotifier(), library: PhotoLibrarySaver(), purchases: purchases, settings: settings,
                           ads: AdsController(settings: settings, purchases: purchases))
    }

    private static func makePurchases() -> any PurchaseProviding {
        #if DEBUG
        let base: any PurchaseProviding = FakePurchases() ?? StoreKitPurchases()
        return DebugPurchases(base: base)
        #else
        return StoreKitPurchases()
        #endif
    }
}
