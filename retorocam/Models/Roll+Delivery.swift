import Foundation

extension Roll {
    static let developDuration: TimeInterval = 72 * 60 * 60

    enum RemainingTime: Equatable {
        case hours(Int), minutes(Int)
    }

    var camera: CameraID { CameraID(rawValue: cameraID) ?? .sunshine }
    var sortedShots: [Shot] { shots.sorted { $0.index < $1.index } }

    /// 届いているがまだ開けていない
    func isDelivered(at now: Date) -> Bool {
        guard state == .developing, let deliverAt else { return false }
        return deliverAt <= now
    }

    func isDeveloping(at now: Date) -> Bool {
        state == .developing && !isDelivered(at: now)
    }

    func deliveryProgress(at now: Date) -> Double {
        guard let sentAt else { return 0 }
        return min(max(now.timeIntervalSince(sentAt) / Self.developDuration, 0), 1)
    }

    func remainingTime(at now: Date) -> RemainingTime {
        let seconds = max((deliverAt ?? now).timeIntervalSince(now), 0)
        if seconds >= 3600 { return .hours(Int((seconds / 3600).rounded(.up))) }
        return .minutes(max(Int((seconds / 60).rounded(.up)), 1))
    }

    /// 例：10/12〜10/19。同じ日なら1日分だけ。
    func shootingPeriod(separator: String = "〜") -> String {
        let dates = shots.map(\.takenAt)
        guard let first = dates.min(), let last = dates.max() else { return "" }
        let start = DeliveryFormat.day(first)
        let end = DeliveryFormat.day(last)
        return start == end ? start : start + separator + end
    }
}

/// 表示用の日付（日本語固定）
enum DeliveryFormat {
    private static func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }

    /// 11月11日（水）
    static func arrival(_ date: Date) -> String { format(date, "M月d日（E）") }
    /// 11/11
    static func arrivalShort(_ date: Date) -> String { format(date, "M/d") }
    /// 9/01
    static func day(_ date: Date) -> String { format(date, "M/dd") }
}
