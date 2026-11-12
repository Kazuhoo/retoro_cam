import Foundation
import SwiftData

@Model
final class Shot {
    var id: UUID
    /// 1〜24
    var index: Int
    var takenAt: Date
    /// Documents からの相対パス（Rolls/<rollID>/<index>.jpg）
    var fileName: String
    var isPortrait: Bool
    var roll: Roll?

    init(id: UUID = UUID(), index: Int, takenAt: Date, fileName: String, isPortrait: Bool) {
        self.id = id
        self.index = index
        self.takenAt = takenAt
        self.fileName = fileName
        self.isPortrait = isPortrait
    }
}
