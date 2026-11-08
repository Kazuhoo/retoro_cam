import Foundation

/// 現在時刻の取得元。デバッグメニューで時間を進められるよう、`Date()` を直接使わない。
nonisolated protocol Clock: Sendable {
    var now: Date { get }
}

nonisolated struct SystemClock: Clock {
    var now: Date { Date() }
}
