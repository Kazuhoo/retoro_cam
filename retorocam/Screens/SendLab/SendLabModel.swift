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
        roll.deliverAt ?? services.clock.now.addingTimeInterval(Roll.developDuration)
    }

    /// 記録は演出の前に確定する。演出中にアプリが終わってもロールは失われない。
    func send() {
        guard stage == .confirm else { return }
        let now = services.clock.now
        services.rolls.send(roll, now: now)
        stage = .sending

        let rollID = roll.id
        let name = roll.camera.theme.name
        Task { await services.notifier.schedule(rollID: rollID, cameraName: name, after: Roll.developDuration) }
        Task {
            try? await Task.sleep(for: .seconds(Self.doneDelay))
            stage = .done
        }
    }
}
