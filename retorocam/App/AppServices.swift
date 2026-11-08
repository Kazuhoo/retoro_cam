import SwiftData

/// 画面をまたいで使うものをまとめる
struct AppServices {
    let clock: any Clock
    let rolls: RollStore
    let photos: PhotoStore
    let notifier: DeliveryNotifier
    let library: PhotoLibrarySaver

    static func makeDefault(context: ModelContext) -> AppServices {
        #if DEBUG
        let clock: any Clock = DebugClock()
        #else
        let clock: any Clock = SystemClock()
        #endif
        return AppServices(clock: clock, rolls: RollStore(context: context), photos: PhotoStore(),
                           notifier: DeliveryNotifier(), library: PhotoLibrarySaver())
    }
}
