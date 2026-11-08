import AVFoundation
import UIKit
import os

/// 実機のカメラ。`AVCaptureSession` の操作はすべて専用キューで行う。
final class CameraService: CameraControlling {
    var onRunningChange: ((Bool) -> Void)?
    var previewContent: CameraPreviewContent { .session(session) }

    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let photoOutput = AVCapturePhotoOutput()
    nonisolated private let sessionQueue = DispatchQueue(label: "retorocam.camera.session")
    private static let logger = Logger(subsystem: "retorocam", category: "Camera")

    private let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    private var isConfigured = false
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var rotation: RotationObserver?
    private var inFlightDelegate: PhotoCaptureDelegate?
    private var observers: [NSObjectProtocol] = []

    init() {
        let center = NotificationCenter.default
        for (name, running) in [(AVCaptureSession.didStartRunningNotification, true),
                                (AVCaptureSession.didStopRunningNotification, false)] {
            observers.append(center.addObserver(forName: name, object: session, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.onRunningChange?(running) }
            })
        }
    }

    func requestAuthorization() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func start() async {
        if !isConfigured {
            guard let device, await configure(device: device) else {
                Self.logger.error("カメラの設定に失敗しました")
                return
            }
            isConfigured = true
            makeRotationObserverIfReady()
        }
        await onSessionQueue { [session] in
            if !session.isRunning { session.startRunning() }
        }
    }

    func stop() async {
        await onSessionQueue { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    func attachPreview(_ layer: AVCaptureVideoPreviewLayer) {
        // 撮影画面に戻るとレイヤーが作り直されるので、回転の監視も作り直す
        previewLayer = layer
        rotation = nil
        makeRotationObserverIfReady()
    }

    func capture(flash: Bool) async throws -> CapturedPhoto {
        guard let rotation, inFlightDelegate == nil else { throw CameraError.notReady }
        let angle = rotation.captureAngle
        defer { inFlightDelegate = nil }

        let data: Data = try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureDelegate { continuation.resume(with: $0) }
            inFlightDelegate = delegate
            sessionQueue.async { [photoOutput] in
                if let connection = photoOutput.connection(with: .video),
                   connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
                let settings = AVCapturePhotoSettings()
                settings.flashMode = flash && photoOutput.supportedFlashModes.contains(.on) ? .on : .off
                settings.photoQualityPrioritization = .speed
                photoOutput.capturePhoto(with: settings, delegate: delegate)
            }
        }
        return CapturedPhoto(data: data, isPortrait: RotationObserver.isPortrait(angle: angle))
    }

    // MARK: - 内部

    private func makeRotationObserverIfReady() {
        guard rotation == nil, isConfigured, let device, let previewLayer else { return }
        rotation = RotationObserver(device: device, previewLayer: previewLayer)
    }

    private func configure(device: AVCaptureDevice) async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [session, photoOutput] in
                session.beginConfiguration()
                defer { session.commitConfiguration() }

                session.sessionPreset = .photo   // センサーの 4:3
                guard let input = try? AVCaptureDeviceInput(device: device),
                      session.canAddInput(input), session.canAddOutput(photoOutput) else {
                    continuation.resume(returning: false)
                    return
                }
                session.addInput(input)
                session.addOutput(photoOutput)
                photoOutput.maxPhotoQualityPrioritization = .speed
                continuation.resume(returning: true)
            }
        }
    }

    private func onSessionQueue(_ work: @escaping @Sendable () -> Void) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async {
                work()
                continuation.resume()
            }
        }
    }
}
