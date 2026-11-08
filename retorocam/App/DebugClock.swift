#if DEBUG
import Foundation

/// 現在時刻を指定の分だけ進めて返す時計。進めた量は再起動後も残る。
nonisolated struct DebugClock: Clock {
    private static let offsetKey = "debugClockOffset"

    var now: Date {
        Date().addingTimeInterval(UserDefaults.standard.double(forKey: Self.offsetKey))
    }

    static func advance(by interval: TimeInterval) {
        let current = UserDefaults.standard.double(forKey: offsetKey)
        UserDefaults.standard.set(current + interval, forKey: offsetKey)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: offsetKey)
    }
}
#endif
