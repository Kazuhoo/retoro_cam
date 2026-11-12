import Foundation
import Observation

@Observable
final class SendLabModel {
    enum Stage { case confirm, sending, done }

    private(set) var stage: Stage = .confirm
    let roll: Roll
    private let services: AppServices

    static let sendAnimation = 0.9
    private static let doneDelay = 0.95

    init(roll: Roll, services: AppServices) {
        self.roll = roll
        self.services = services
    }

    /// 届く予定の日時（現像に出す前は、今から72時間後）
    var arrival: Date {
        roll.deliverAt ?? services.clock.now.addingTimeInterval(Roll.developDurationForSending)
    }

    /// 記録は演出の前に確定する。演出中にアプリが終わってもロールは失われない。
    func send() {
        guard stage == .confirm else { return }
        let now = services.clock.now
        // お届けと通知は、現像に出した時点の同じ値で決める
        let duration = Roll.developDurationForSending
        services.rolls.send(roll, now: now, duration: duration)
        stage = .sending

        let rollID = roll.id
        let name = roll.camera.theme.name
        Task { await services.notifier.schedule(rollID: rollID, cameraName: name, after: duration) }
        Task {
            try? await Task.sleep(for: .seconds(Self.doneDelay))
            stage = .done
        }
    }
}
