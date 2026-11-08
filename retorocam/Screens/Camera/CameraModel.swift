import Foundation
import Observation
import os

@Observable
final class CameraModel {
    enum Access { case unknown, granted, denied }

    /// 撮影時の合図
    enum Signal {
        case dark, white
        var duration: Double {
            self == .dark ? Theme.Viewfinder.darkSignalDuration : Theme.Viewfinder.whiteSignalDuration
        }
    }

    private(set) var access: Access = .unknown
    private(set) var isSessionRunning = false
    private(set) var state = ShootingState()
    private(set) var isFlashOn = false
    private(set) var hasNewDelivery = false
    private(set) var isBouncing = false
    private(set) var signal: Signal?
    /// シャッターを押してから保存が終わるまでのコマ番号
    private(set) var reservedFrames: Set<Int> = []
    /// まだカメラを開けていないときは nil
    private(set) var roll: Roll?

    let camera: any CameraControlling

    private let clock: any Clock
    private let processor = FilmProcessor()
    private let photos = PhotoStore()
    private let rolls: RollStore
    private var isCapturing = false
    private var lastPressedFrame: Int?
    private static let logger = Logger(subsystem: "retorocam", category: "Camera")

    init(camera: any CameraControlling, clock: any Clock, rolls: RollStore) {
        self.camera = camera
        self.clock = clock
        self.rolls = rolls
        roll = rolls.shootingRoll()
        camera.onRunningChange = { [weak self] in self?.isSessionRunning = $0 }
    }

    var cameraID: CameraID { roll?.camera ?? .sunshine }
    /// 撮影の途中か（現像に出したロールは含めない）
    var hasShootingRoll: Bool { roll?.state == .shooting }
    var exposed: Int { (roll?.shots.count ?? 0) + reservedFrames.count }
    var remaining: Int { state.displayedRemaining(exposed: exposed) }
    var isEmpty: Bool { state.isEmpty(exposed: exposed) }
    var canShoot: Bool { state.canShoot(exposed: exposed) }
    /// 加工中のコマが残っている間は現像に出せない
    var canSend: Bool { isEmpty && reservedFrames.isEmpty }

    func activate() async {
        if access == .unknown {
            access = await camera.requestAuthorization() ? .granted : .denied
        }
        if access == .granted { await camera.start() }
    }

    func deactivate() async {
        await camera.stop()
    }

    // MARK: - シャッター

    /// コマ番号は押した瞬間に確定する。加工や保存に失敗したらそのコマを取り消す。
    func shutter() {
        guard let roll, isSessionRunning, !isCapturing, canShoot, let frame = nextFrame() else { return }

        let flash = isFlashOn
        let takenAt = clock.now
        let options = CaptureOptions()
        let look = cameraID.look
        reservedFrames.insert(frame)
        lastPressedFrame = frame
        state.markShot()
        isFlashOn = false
        isCapturing = true
        showSignal(flash ? .white : .dark)

        Task {
            do {
                let photo = try await captureReleasingGate(flash: flash)
                guard let jpeg = await processor.develop(
                    photoData: photo.data, look: look, date: takenAt,
                    isPortrait: photo.isPortrait, options: options
                ) else { throw CameraError.noPhotoData }
                let fileName = try await photos.save(jpeg, rollID: roll.id, index: frame)
                rolls.addShot(to: roll, index: frame, takenAt: takenAt,
                              fileName: fileName, isPortrait: photo.isPortrait)
                reservedFrames.remove(frame)
            } catch {
                Self.logger.error("撮影に失敗しました: \(error.localizedDescription, privacy: .public)")
                cancelFrame(frame)
            }
        }
    }

    private func captureReleasingGate(flash: Bool) async throws -> CapturedPhoto {
        defer { isCapturing = false }
        return try await camera.capture(flash: flash)
    }

    /// 取り消されたコマの番号も再利用する
    private func nextFrame() -> Int? {
        let used = Set(roll?.shots.map(\.index) ?? []).union(reservedFrames)
        return (1...ShootingState.totalFrames).first { !used.contains($0) }
    }

    private func cancelFrame(_ frame: Int) {
        reservedFrames.remove(frame)
        if frame == lastPressedFrame, !state.isWound {
            state.restoreWound()
        }
    }

    private func showSignal(_ newSignal: Signal) {
        signal = newSignal
        Task {
            try? await Task.sleep(for: .seconds(newSignal.duration))
            signal = nil
        }
    }

    // MARK: - 巻き上げ・フラッシュ

    func wind(by dx: CGFloat) {
        switch state.wind(by: dx, exposed: exposed) {
        case .ignored, .advanced(crossedDetent: false):
            break
        case .advanced(crossedDetent: true):
            Haptics.windTick()
        case .completed:
            Haptics.windComplete()
        case .bounced:
            bounce()
        }
    }

    func windByKey() {
        wind(by: ShootingState.fullWind / 3)
    }

    private func bounce() {
        guard !isBouncing else { return }
        isBouncing = true
        Task {
            try? await Task.sleep(for: .seconds(Theme.Dial.bounceDuration))
            isBouncing = false
        }
    }

    func setFlash(_ on: Bool) {
        guard on != isFlashOn else { return }
        isFlashOn = on
        Haptics.flashSwitch()
    }

    // MARK: - ロール

    /// 選んだカメラを開ける
    func openRoll(camera: CameraID) {
        roll = rolls.openRoll(camera: camera, now: clock.now)
        state = ShootingState()
        isFlashOn = false
        lastPressedFrame = nil
        refreshDeliveries()
    }

    func refreshDeliveries() {
        let now = clock.now
        hasNewDelivery = rolls.allRolls().contains { $0.isDelivered(at: now) }
    }

    // MARK: - デバッグ

    #if DEBUG
    /// ロールを残り枚数の状態にする（処理中のコマがあるときは何もしない）
    func debugReset(remaining: Int) {
        guard let roll, reservedFrames.isEmpty else { return }
        Task {
            await rolls.debugSetExposed(ShootingState.totalFrames - remaining, on: roll,
                                        photos: photos, now: clock.now)
            state.restoreWound()
            isFlashOn = false
        }
    }
    #endif

    #if targetEnvironment(simulator)
    func simulatorShutter(portrait: Bool) {
        (camera as? SimulatedCameraService)?.shootsPortrait = portrait
        shutter()
    }
    #endif
}

extension CameraModel {
    static func makeDefault(services: AppServices) -> CameraModel {
        #if targetEnvironment(simulator)
        return CameraModel(camera: SimulatedCameraService(), clock: services.clock, rolls: services.rolls)
        #else
        return CameraModel(camera: CameraService(), clock: services.clock, rolls: services.rolls)
        #endif
    }
}
