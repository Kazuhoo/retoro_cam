import Foundation
import UserNotifications

/// 届いたことを知らせるローカル通知。アプリを開いている間は表示しない（デリゲートを置かない）。
struct DeliveryNotifier {
    /// 初めて現像に出すときに許可を求め、届く時刻に通知を予約する
    func schedule(rollID: UUID, cameraName: String, after interval: TimeInterval) async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

        let content = UNMutableNotificationContent()
        content.body = String(localized: "写真が届きました。\(cameraName) の24枚です。")
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        let request = UNNotificationRequest(identifier: rollID.uuidString, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
