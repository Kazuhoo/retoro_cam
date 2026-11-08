import Foundation

/// 加工済みの写真を `Documents/Rolls/<rollID>/<index>.jpg` に保存する。
actor PhotoStore {
    private let root: URL

    init(root: URL = URL.documentsDirectory.appending(path: "Rolls", directoryHint: .isDirectory)) {
        self.root = root
    }

    /// 次の連番で保存し、保存先を返す。M2 で番号は Roll / Shot から渡す形に変える。
    func saveNext(_ data: Data, rollID: UUID) throws -> URL {
        let folder = root.appending(path: rollID.uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let used = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            .compactMap { Int(($0 as NSString).deletingPathExtension) }
        let url = folder.appending(path: "\((used.max() ?? 0) + 1).jpg")
        try data.write(to: url, options: .atomic)
        return url
    }
}
