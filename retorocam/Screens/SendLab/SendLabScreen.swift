import SwiftUI

struct SendLabScreen: View {
    @State private var model: SendLabModel
    let onLater: () -> Void
    let onOpenNext: () -> Void

    init(roll: Roll, services: AppServices, onLater: @escaping () -> Void, onOpenNext: @escaping () -> Void) {
        _model = State(initialValue: SendLabModel(roll: roll, services: services))
        self.onLater = onLater
        self.onOpenNext = onOpenNext
    }

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            HStack(spacing: Theme.SendLab.gap) {
                artwork.frame(width: 300, height: 200)
                details.frame(maxWidth: 340, alignment: .leading)
            }
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
    }

    @ViewBuilder
    private var artwork: some View {
        if model.stage == .done {
            arrivalSlot
        } else {
            let leaving = model.stage == .sending
            CameraIllustration(camera: model.roll.camera)
                .rotationEffect(.degrees(leaving ? 8 : 0))
                .offset(x: leaving ? 520 : 0)
                .opacity(leaving ? 0 : 1)
                .animation(.timingCurve(0.5, 0, 0.75, 0, duration: SendLabModel.sendAnimation), value: leaving)
        }
    }

    private var arrivalSlot: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.SendLab.dash, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            VStack(spacing: 6) {
                Text(verbatim: DeliveryFormat.arrivalShort(model.arrival))
                    .font(Theme.dotFont(size: 32))
                    .foregroundStyle(Theme.Common.accent)
                Text("お届け予定").font(Theme.Text.hint).foregroundStyle(Theme.Common.subText)
            }
            .padding(.top, 52)
        }
        .frame(width: 240, height: 150)
    }

    @ViewBuilder
    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            if model.stage == .done {
                Text("現像に出しました").font(Theme.SendLab.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text("3日後、\(DeliveryFormat.arrival(model.arrival))ごろに届きます。")
                    Text("届いたらお知らせします。")
                    Text("待っている間も、新しいカメラで撮れます。")
                }
                .font(Theme.SendLab.body)
                .foregroundStyle(Theme.Common.subText)
                Button(action: onOpenNext) { primaryLabel("新しいカメラを開ける") }
            } else {
                Text(verbatim: "\(model.roll.camera.theme.name) ・ 24EXP")
                    .font(Theme.Text.exposure)
                    .foregroundStyle(Theme.Common.subText)
                VStack(alignment: .leading, spacing: 0) {
                    Text("24枚、撮り切りました。")
                    Text("現像に出しますか？")
                }
                .font(Theme.SendLab.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text("写真は\(DeliveryFormat.arrival(model.arrival))ごろ、封筒に入って届きます。")
                    Text("同じカメラは、新しく開ければまた使えます。")
                }
                .font(Theme.SendLab.body)
                .foregroundStyle(Theme.Common.subText)
                HStack(spacing: 12) {
                    Button(action: onLater) {
                        Text("あとで")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Common.text)
                            .frame(height: Theme.Status.developHeight)
                            .padding(.horizontal, 22)
                            .background(Theme.Common.button, in: Capsule())
                    }
                    Button { model.send() } label: { primaryLabel("現像に出す") }
                }
                .disabled(model.stage != .confirm)
            }
        }
    }

    private func primaryLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(Theme.Text.develop)
            .foregroundStyle(Theme.Common.background)
            .frame(height: Theme.Status.developHeight)
            .padding(.horizontal, Theme.Status.developPadding)
            .background(Theme.Common.accent, in: Capsule())
    }
}
