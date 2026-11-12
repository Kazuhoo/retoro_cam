import Foundation
import SwiftData
import os

/// ロールの取得と更新。
final class RollStore {
    let context: ModelContext
    private static let logger = Logger(subsystem: "retorocam", category: "RollStore")

    init(context: ModelContext) {
        self.context = context
    }

    /// 撮影中のロール。なければ nil
    func shootingRoll() -> Roll? {
        // #Predicate は enum の比較で問題が起きやすいので Swift 側で絞り込む
        allRolls().filter { $0.state == .shooting }.max { $0.createdAt < $1.createdAt }
    }

    /// カメラを開ける。撮影中のロールがあれば、新しくは開けずにそれを返す。
    func openRoll(camera: CameraID, now: Date) -> Roll {
        if let shooting = shootingRoll() { return shooting }
        let roll = Roll(cameraID: camera.rawValue, createdAt: now)
        context.insert(roll)
        save()
        return roll
    }

    func addShot(to roll: Roll, index: Int, takenAt: Date, fileName: String, isPortrait: Bool) {
        let shot = Shot(index: index, takenAt: takenAt, fileName: fileName, isPortrait: isPortrait)
        context.insert(shot)
        shot.roll = roll
        save()
    }

    func allRolls() -> [Roll] {
        (try? context.fetch(FetchDescriptor<Roll>())) ?? []
    }

    func send(_ roll: Roll, now: Date, duration: TimeInterval) {
        roll.state = .developing
        roll.sentAt = now
        roll.deliverAt = now.addingTimeInterval(duration)
        save()
    }

    func markOpened(_ roll: Roll, now: Date) {
        roll.state = .opened
        roll.openedAt = now
        save()
    }

    func markSavedToPhotos(_ roll: Roll, now: Date) {
        roll.savedToPhotosAt = now
        save()
    }

    func save() {
        do {
            try context.save()
        } catch {
            Self.logger.error("保存に失敗しました: \(error.localizedDescription, privacy: .public)")
        }
    }
}
