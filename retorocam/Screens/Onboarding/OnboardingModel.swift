import Observation
import SwiftUI

@Observable
final class OnboardingModel {
    struct Page {
        let label: LocalizedStringKey
        let title: LocalizedStringKey
        let body: LocalizedStringKey
    }

    static let pages = [
        Page(label: "ようこそ", title: "撮って、待って、\n受け取るカメラ",
             body: "撮った写真は、その場では見られません。\n使い捨てカメラのように、現像されるまでのお楽しみです。"),
        Page(label: "シャッター", title: "横に持って、\n音量ボタンで撮影",
             body: "画面にシャッターボタンはありません。\n本体の上にきた音量ボタンを押すと撮れます。"),
        Page(label: "巻き上げ", title: "1枚撮ったら、\nダイヤルを巻き上げる",
             body: "右上のダイヤルを右になぞると、残り枚数が回ります。\n数字が回り切ると、次の1枚が撮れます。"),
        Page(label: "現像", title: "24枚撮り切ったら、\nカメラごと現像に出す",
             body: "現像には3日かかります。\n写真は封筒に入って届き、開けるとまとめて写真アプリに保存されます。"),
    ]

    private(set) var index = 0
    private(set) var isFinishing = false

    var page: Page { Self.pages[index] }
    var isFirst: Bool { index == 0 }
    var isLast: Bool { index == Self.pages.count - 1 }

    func next() { if !isLast { index += 1 } }
    func back() { if !isFirst { index -= 1 } }
    /// スキップは最後のページへ（カメラの許可はそこで求める）
    func skip() { index = Self.pages.count - 1 }

    func finish(_ action: () async -> Void) async {
        guard !isFinishing else { return }
        isFinishing = true
        await action()
        isFinishing = false
    }
}
