import AVFoundation
import Foundation
import Observation
import os

@Observable
final class CameraModel {
    enum Access { case unknown, granted, denied }

    private(set) var access: Access = .unknown
    private(set) var isSessionRunning = false

    let camera: any CameraControlling

    private let clock: any Clock
    private let processor = FilmProcessor()
    private let store = PhotoStore()
    private let cameraID: CameraID
    private var isShooting = false

    // M2 で Roll に置き換えるまでの、開発用の固定ロール
    private static let developmentRollID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private static let logger = Logger(subsystem: "retorocam", category: "Camera")

    init(camera: any CameraControlling, clock: any Clock, cameraID: CameraID) {
        self.camera = camera
        self.clock = clock
        self.cameraID = cameraID
        camera.onRunningChange = { [weak self] in self?.isSessionRunning = $0 }
    }

    static func makeDefault() -> CameraModel {
        #if targetEnvironment(simulator)
        let environment = ProcessInfo.processInfo.environment["RETORO_CAMERA"]
        return CameraModel(camera: SimulatedCameraService(), clock: SystemClock(),
                           cameraID: environment.flatMap(CameraID.init(rawValue:)) ?? .sunshine)
        #else
        return CameraModel(camera: CameraService(), clock: SystemClock(), cameraID: .sunshine)
        #endif
    }

    func activate() async {
        if access == .unknown {
            access = await camera.requestAuthorization() ? .granted : .denied
        }
        if access == .granted { await camera.start() }
    }

    func deactivate() async {
        await camera.stop()
    }

    /// シャッター。撮った瞬間の時刻と設定で加工して保存する。写真は見せない。
    func shutter() {
        guard isSessionRunning, !isShooting else { return }
        isShooting = true
        let takenAt = clock.now
        let options = CaptureOptions()

        Task {
            defer { isShooting = false }
            do {
                let photo = try await camera.capture()
                guard let jpeg = await processor.develop(
                    photoData: photo.data, look: cameraID.look, date: takenAt,
                    isPortrait: photo.isPortrait, options: options
                ) else { throw CameraError.noPhotoData }
                let url = try await store.saveNext(jpeg, rollID: Self.developmentRollID)
                Self.logger.info("保存しました: \(url.path, privacy: .public)")
            } catch {
                Self.logger.error("撮影に失敗しました: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    #if targetEnvironment(simulator)
    func simulatorShutter(portrait: Bool) {
        (camera as? SimulatedCameraService)?.shootsPortrait = portrait
        shutter()
    }
    #endif
}
