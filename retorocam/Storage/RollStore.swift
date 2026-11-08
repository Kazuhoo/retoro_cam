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

    /// 撮影中のロールを返す。なければ指定のカメラで開ける。
    func currentRoll(openingIfNone camera: CameraID, now: Date) -> Roll {
        // #Predicate は enum の比較で問題が起きやすいので Swift 側で絞り込む
        let rolls = (try? context.fetch(FetchDescriptor<Roll>())) ?? []
        if let shooting = rolls.filter({ $0.state == .shooting }).max(by: { $0.createdAt < $1.createdAt }) {
            return shooting
        }
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

    func save() {
        do {
            try context.save()
        } catch {
            Self.logger.error("保存に失敗しました: \(error.localizedDescription, privacy: .public)")
        }
    }
}
