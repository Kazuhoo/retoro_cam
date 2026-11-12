import SwiftUI

/// 未開封の封筒。ふたを上へなぞってめくる。
struct EnvelopeOpeningView: View {
    let model: PrintsModel

    @State private var dragStart: CGFloat?

    var body: some View {
        HStack(spacing: Theme.Prints.envelopeGap) {
            ClosedEnvelope(camera: model.roll.camera, period: model.roll.shootingPeriod(separator: "-"),
                           width: Theme.Envelope.largeWidth, flapProgress: model.flap)
                .contentShape(Rectangle())
                .animation(.easeOut(duration: PrintsModel.flapOpenDuration), value: model.flap == 0 || model.flap == 1)
                .gesture(flapGesture)

            VStack(alignment: .leading, spacing: 14) {
                Text("写真が届きました").font(.system(size: 18, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("ふたを上へめくって開けましょう。")
                    Text("写真は1枚ずつスワイプしてめくれます。")
                }
                .font(Theme.SendLab.body)
                .foregroundStyle(Theme.Common.subText)
                Button { withAnimation { model.open() } } label: {
                    Text("ボタンで開ける")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.Common.text)
                        .frame(height: Theme.Status.developHeight)
                        .padding(.horizontal, 26)
                        .background(Theme.Common.button, in: Capsule())
                }
            }
            .frame(maxWidth: 240, alignment: .leading)
        }
    }

    private var flapGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                let start = dragStart ?? value.location.y
                dragStart = start
                model.dragFlap((start - value.location.y) / Theme.Prints.flapDragDistance)
            }
            .onEnded { _ in
                dragStart = nil
                model.releaseFlap()
            }
    }
}
