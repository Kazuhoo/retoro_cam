#if DEBUG
import SwiftData
import UIKit

extension RollStore {
    /// 撮影済みの枚数を指定の数にする。増やす分はダミーの写真で埋める。
    func debugSetExposed(_ count: Int, on roll: Roll, photos: PhotoStore, now: Date) async {
        for shot in roll.shots where shot.index > count {
            await photos.delete(fileName: shot.fileName)
            context.delete(shot)
        }

        let existing = Set(roll.shots.filter { $0.index <= count }.map(\.index))
        for index in 1...max(count, 1) where index <= count && !existing.contains(index) {
            guard let data = Self.placeholderJPEG(),
                  let fileName = try? await photos.save(data, rollID: roll.id, index: index) else { continue }
            addShot(to: roll, index: index, takenAt: now, fileName: fileName, isPortrait: false)
        }
        save()
    }

    private static func placeholderJPEG() -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let size = FilmProcessor.outputSize
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.darkGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }.jpegData(compressionQuality: 0.5)
    }
}
#endif
