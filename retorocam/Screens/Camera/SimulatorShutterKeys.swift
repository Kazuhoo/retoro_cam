import SwiftUI
import UIKit

/// シミュレータでは音量ボタンの代わりにキーボードで撮る（スペース／Return＝横、P＝縦）。
struct SimulatorShutterKeys: ViewModifier {
    let model: CameraModel

    func body(content: Content) -> some View {
        #if targetEnvironment(simulator)
        KeyHost(content: content, model: model)
        #else
        content
        #endif
    }
}

#if targetEnvironment(simulator)
private struct KeyHost<Content: View>: View {
    let content: Content
    let model: CameraModel
    @FocusState private var isFocused: Bool

    var body: some View {
        content
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onAppear {
                isFocused = true
                // シミュレータは持ち方がないので、音量ボタン側を上にした横向きで表示する
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                    .requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
            }
            .onKeyPress(keys: [.space, .return, "p"]) { press in
                model.simulatorShutter(portrait: press.characters == "p")
                return .handled
            }
    }
}
#endif
