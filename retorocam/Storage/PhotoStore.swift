import Foundation

/// 加工済みの写真を `Documents/Rolls/<rollID>/<index>.jpg` に保存する。
actor PhotoStore {
    private let root: URL

    init(root: URL = URL.documentsDirectory) {
        self.root = root
    }

    /// 保存して、Documents からの相対パスを返す
    func save(_ data: Data, rollID: UUID, index: Int) throws -> String {
        let fileName = "Rolls/\(rollID.uuidString)/\(index).jpg"
        let url = root.appending(path: fileName)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    nonisolated func url(for fileName: String) -> URL {
        root.appending(path: fileName)
    }

    func delete(fileName: String) {
        try? FileManager.default.removeItem(at: root.appending(path: fileName))
    }
}
