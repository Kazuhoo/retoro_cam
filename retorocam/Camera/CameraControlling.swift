import AVFoundation
import UIKit

nonisolated struct CapturedPhoto: Sendable {
    let data: Data
    let isPortrait: Bool
}

enum CameraPreviewContent {
    case session(AVCaptureSession)
    case image(UIImage)
}

enum CameraError: Error {
    case notReady
    case noPhotoData
}

/// 実機のカメラとシミュレータ用のダミーを同じ形で扱う
protocol CameraControlling: AnyObject {
    var previewContent: CameraPreviewContent { get }
    var onRunningChange: ((Bool) -> Void)? { get set }

    func requestAuthorization() async -> Bool
    func start() async
    func stop() async
    func attachPreview(_ layer: AVCaptureVideoPreviewLayer)
    func capture(flash: Bool) async throws -> CapturedPhoto
}
