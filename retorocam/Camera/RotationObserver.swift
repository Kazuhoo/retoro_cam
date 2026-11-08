import AVFoundation

/// 端末の傾きからプレビューと撮影の角度を求める。プレビューの角度は自動で反映する。
final class RotationObserver {
    private let coordinator: AVCaptureDevice.RotationCoordinator
    private var observation: NSKeyValueObservation?

    init(device: AVCaptureDevice, previewLayer: AVCaptureVideoPreviewLayer) {
        coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
        observation = coordinator.observe(
            \.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]
        ) { [weak previewLayer] coordinator, _ in
            let angle = coordinator.videoRotationAngleForHorizonLevelPreview
            DispatchQueue.main.async {
                guard let connection = previewLayer?.connection,
                      connection.isVideoRotationAngleSupported(angle) else { return }
                connection.videoRotationAngle = angle
            }
        }
    }

    var captureAngle: CGFloat {
        coordinator.videoRotationAngleForHorizonLevelCapture
    }

    /// 90度・270度は縦持ち
    static func isPortrait(angle: CGFloat) -> Bool {
        Int(angle.rounded()) % 180 != 0
    }
}
