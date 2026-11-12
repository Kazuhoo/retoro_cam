import AVFoundation
import SwiftUI
import UIKit

/// 素の映像を出すファインダー。シミュレータではダミー画像を出す。
struct CameraPreviewView: View {
    let camera: any CameraControlling

    var body: some View {
        switch camera.previewContent {
        case .session(let session):
            SessionPreview(session: session) { camera.attachPreview($0) }
        case .image(let image):
            Image(uiImage: image).resizable().scaledToFill()
        }
    }
}

private struct SessionPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let onReady: (AVCaptureVideoPreviewLayer) -> Void

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill   // 3:2 の枠で写真と同じ範囲になる
        view.onWindow = onReady
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

private final class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    var onWindow: ((AVCaptureVideoPreviewLayer) -> Void)?

    // RotationCoordinator が画面の向きを見られるよう、ウィンドウに載ってから渡す
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { onWindow?(previewLayer) }
    }
}
