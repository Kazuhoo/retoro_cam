#if DEBUG
import Foundation
import Observation

/// 設定画面のデバッグ欄の値（DEBUG ビルドのみ）
@Observable
final class DebugSettings {
    enum PurchaseState: String, CaseIterable {
        case actual, allOwned, none

        var title: String {
            switch self {
            case .actual: "実際の購入どおり"
            case .allOwned: "全部購入済み"
            case .none: "未購入"
            }
        }
    }

    static let shared = DebugSettings()
    static let instantDevelopDuration: TimeInterval = 10

    private enum Key {
        static let purchaseState = "debug.purchaseState"
        static let instantDevelop = "debug.instantDevelop"
        static let hidesDebugButtons = "debug.hidesDebugButtons"
    }

    @ObservationIgnored private let defaults = UserDefaults.standard

    var purchaseState: PurchaseState { didSet { defaults.set(purchaseState.rawValue, forKey: Key.purchaseState) } }
    var instantDevelop: Bool { didSet { defaults.set(instantDevelop, forKey: Key.instantDevelop) } }
    var hidesDebugButtons: Bool { didSet { defaults.set(hidesDebugButtons, forKey: Key.hidesDebugButtons) } }

    private init() {
        purchaseState = defaults.string(forKey: Key.purchaseState).flatMap(PurchaseState.init(rawValue:)) ?? .actual
        instantDevelop = defaults.bool(forKey: Key.instantDevelop)
        hidesDebugButtons = defaults.bool(forKey: Key.hidesDebugButtons)
    }
}
#endif
