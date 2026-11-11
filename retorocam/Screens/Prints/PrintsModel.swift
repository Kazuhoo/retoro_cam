import Observation
import UIKit

@Observable
final class PrintsModel {
    enum SaveResult { case none, saved, failed }

    let roll: Roll
    let shots: [Shot]
    private(set) var showsPhotos: Bool
    private(set) var flap: CGFloat = 0
    private(set) var index = 0
    private(set) var images: [Int: UIImage] = [:]
    private(set) var saveResult: SaveResult = .none
    private let services: AppServices

    static let flapOpenThreshold: CGFloat = 0.6
    static let flapOpenDuration = 0.45

    init(roll: Roll, services: AppServices) {
        self.roll = roll
        self.services = services
        shots = roll.sortedShots
        showsPhotos = roll.state == .opened
    }

    var isLast: Bool { index >= shots.count - 1 }
    var current: Shot? { shots.indices.contains(index) ? shots[index] : nil }

    // MARK: - 表示

    func appear() {
        loadAround()
        if showsPhotos { saveToLibraryIfNeeded() }
    }

    func go(_ delta: Int) {
        let next = min(max(index + delta, 0), shots.count - 1)
        guard next != index else { return }
        index = next
        loadAround()
    }

    private func loadAround() {
        for position in max(index - 1, 0)...min(index + 2, max(shots.count - 1, 0)) where images[position] == nil && shots.indices.contains(position) {
            let url = services.photos.url(for: shots[position].fileName)
            Task {
                images[position] = await ImageLoader.load(url)
            }
        }
    }

    // MARK: - 封筒

    func dragFlap(_ progress: CGFloat) {
        flap = min(max(progress, 0), 1)
    }

    func releaseFlap() {
        if flap > Self.flapOpenThreshold {
            open()
        } else {
            flap = 0
        }
    }

    /// 開けた瞬間に記録して保存する。写真に切り替わるのはふたの動きのあと。
    func open() {
        guard roll.state != .opened else { return }
        flap = 1
        Haptics.envelopeOpened()
        SoundPlayer.play(.envelopeFlap)
        services.rolls.markOpened(roll, now: services.clock.now)
        saveToLibraryIfNeeded()
        Task {
            try? await Task.sleep(for: .seconds(Self.flapOpenDuration))
            showsPhotos = true
        }
    }

    // MARK: - 写真アプリ

    private func saveToLibraryIfNeeded() {
        guard roll.savedToPhotosAt == nil else { return }
        let items = shots.map {
            PhotoLibrarySaver.Item(url: services.photos.url(for: $0.fileName), takenAt: $0.takenAt)
        }
        Task {
            if await services.library.save(items) {
                services.rolls.markSavedToPhotos(roll, now: services.clock.now)
                saveResult = .saved
            } else {
                saveResult = .failed
            }
        }
    }
}
