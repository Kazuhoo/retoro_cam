import Foundation
import SwiftData

enum RollState: String, Codable {
    case shooting, developing, delivered, opened
}

@Model
final class Roll {
    var id: UUID
    var cameraID: String
    var createdAt: Date
    var state: RollState
    var sentAt: Date?
    var deliverAt: Date?
    var openedAt: Date?
    var savedToPhotosAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \Shot.roll) var shots: [Shot] = []

    init(id: UUID = UUID(), cameraID: String, createdAt: Date, state: RollState = .shooting) {
        self.id = id
        self.cameraID = cameraID
        self.createdAt = createdAt
        self.state = state
    }
}
