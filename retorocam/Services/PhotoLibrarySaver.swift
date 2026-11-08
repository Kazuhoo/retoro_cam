import Foundation
import Photos

/// 写真アプリへの保存（追加のみ）。ロール1本を1回の変更で保存するので、途中までの重複は起きない。
nonisolated struct PhotoLibrarySaver: Sendable {
    struct Item: Sendable {
        let url: URL
        let takenAt: Date
    }

    func save(_ items: [Item]) async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                for item in items {
                    let request = PHAssetCreationRequest.forAsset()
                    request.creationDate = item.takenAt
                    request.addResource(with: .photo, fileURL: item.url, options: nil)
                }
            }
            return true
        } catch {
            return false
        }
    }
}
