#if targetEnvironment(simulator)
import AVFoundation
import UIKit

/// シミュレータ用。カメラの代わりにダミー画像を返す。
final class SimulatedCameraService: CameraControlling {
    var onRunningChange: ((Bool) -> Void)?
    var previewContent: CameraPreviewContent { .image(Self.render(CGSize(width: 1014, height: 676))) }

    /// 次の1枚を縦持ちの写真として扱う
    var shootsPortrait = false

    func requestAuthorization() async -> Bool { true }
    func start() async { onRunningChange?(true) }
    func stop() async { onRunningChange?(false) }
    func attachPreview(_ layer: AVCaptureVideoPreviewLayer) {}

    func capture(flash: Bool) async throws -> CapturedPhoto {
        let portrait = shootsPortrait
        shootsPortrait = false
        let size = portrait ? CGSize(width: 1512, height: 2016) : CGSize(width: 2016, height: 1512)
        guard let data = Self.render(size).jpegData(compressionQuality: 0.95) else {
            throw CameraError.noPhotoData
        }
        return CapturedPhoto(data: data, isPortrait: portrait)
    }

    /// 空・地面・太陽と、上下が分かる印の入ったダミー画像
    private static func render(_ size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let cg = renderer.cgContext
            let colors = [UIColor.systemTeal.cgColor, UIColor.systemYellow.cgColor, UIColor.systemGreen.cgColor]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray,
                                         locations: [0, 0.6, 1]) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            let unit = min(size.width, size.height)
            UIColor.systemOrange.setFill()
            cg.fillEllipse(in: CGRect(x: size.width * 0.62, y: size.height * 0.12, width: unit * 0.28, height: unit * 0.28))

            let label = NSAttributedString(string: "▲ UP", attributes: [
                .font: UIFont.boldSystemFont(ofSize: unit * 0.1),
                .foregroundColor: UIColor.white,
            ])
            label.draw(at: CGPoint(x: size.width * 0.08, y: size.height * 0.1))
        }
    }
}
#endif
