import SwiftUI

/// 右矢印キーで巻き上げる（アクセシビリティ）。
/// シミュレータでは音量ボタンの代わりにキーでも撮る（スペース／Return＝横、P＝縦）。
struct CameraKeyboardControls: ViewModifier {
    let model: CameraModel
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
            .onAppear { isFocused = true }
            .onKeyPress(.rightArrow) {
                model.windByKey()
                return .handled
            }
            #if targetEnvironment(simulator)
            .onKeyPress(keys: [.space, .return, "p"]) { press in
                model.simulatorShutter(portrait: press.characters == "p")
                return .handled
            }
            #endif
    }
}
