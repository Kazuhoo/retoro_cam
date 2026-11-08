import Foundation
import Observation

@Observable
final class DarkroomModel {
    private(set) var now: Date
    private(set) var developing: [Roll] = []
    /// 未開封が先、その中は届いた順に新しいものから
    private(set) var arrived: [Roll] = []
    private let services: AppServices

    init(services: AppServices) {
        self.services = services
        now = services.clock.now
        refresh()
    }

    func refresh() {
        now = services.clock.now
        let rolls = services.rolls.allRolls()
        developing = rolls.filter { $0.isDeveloping(at: now) }
            .sorted { ($0.deliverAt ?? .distantFuture) < ($1.deliverAt ?? .distantFuture) }
        arrived = rolls.filter { $0.isDelivered(at: now) || $0.state == .opened }
            .sorted { lhs, rhs in
                if (lhs.state == .opened) != (rhs.state == .opened) { return rhs.state == .opened }
                return (lhs.deliverAt ?? .distantPast) > (rhs.deliverAt ?? .distantPast)
            }
    }
}
