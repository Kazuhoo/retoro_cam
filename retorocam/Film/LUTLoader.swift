import Foundation

nonisolated struct LUTCube: Sendable {
    let data: Data
    let dimension: Int
}

nonisolated enum LUTLoader {
    /// .cube を CIColorCube 用の RGBA Float32 データに変換する（並び順は .cube と同じく R が最速）
    static func load(named name: String, in bundle: Bundle = .main) -> LUTCube? {
        guard let url = bundle.url(forResource: name, withExtension: "cube"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }

        var size = 0
        var values: [Float] = []
        for line in text.split(whereSeparator: \.isNewline) {
            let s = line.trimmingCharacters(in: .whitespaces)
            if s.hasPrefix("LUT_3D_SIZE") {
                size = Int(s.split(separator: " ").last ?? "") ?? 0
                values.reserveCapacity(size * size * size * 4)
            } else if let first = s.first, first.isNumber || first == "-" || first == "." {
                let rgb = s.split(separator: " ").compactMap { Float($0) }
                guard rgb.count == 3 else { continue }
                values.append(contentsOf: [rgb[0], rgb[1], rgb[2], 1.0])
            }
        }

        guard size > 0, values.count == size * size * size * 4 else { return nil }
        return LUTCube(data: values.withUnsafeBufferPointer { Data(buffer: $0) }, dimension: size)
    }
}
