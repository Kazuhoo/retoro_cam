import AVKit
import SwiftUI
import UIKit

/// 音量ボタン（上下とも）とカメラコントロールをシャッターとして受ける透明なビュー。
struct CaptureEventView: UIViewRepresentable {
    let isEnabled: Bool
    let onShutter: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        let coordinator = context.coordinator
        let interaction = AVCaptureEventInteraction { event in
            if event.phase == .began { coordinator.onShutter?() }
        }
        coordinator.interaction = interaction
        view.addInteraction(interaction)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onShutter = onShutter
        context.coordinator.interaction?.isEnabled = isEnabled
    }

    final class Coordinator {
        var onShutter: (() -> Void)?
        var interaction: AVCaptureEventInteraction?
    }
}
