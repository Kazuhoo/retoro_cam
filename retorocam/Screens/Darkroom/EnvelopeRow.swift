import SwiftUI

/// 届いた封筒の1行（未開封／開封済み）
struct EnvelopeRow: View {
    let roll: Roll

    private var isOpened: Bool { roll.state == .opened }

    var body: some View {
        HStack(spacing: 16) {
            envelope
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(isOpened ? "開封済み" : "未開封").font(Theme.Darkroom.button)
                    if !isOpened {
                        Text("新着")
                            .font(Theme.Text.hintBold)
                            .foregroundStyle(Theme.Common.background)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 1)
                            .background(Theme.Common.accent, in: Capsule())
                    }
                }
                Text(verbatim: "\(roll.shootingPeriod()) ・ \(roll.shots.count)枚")
                    .font(Theme.Darkroom.rowDetail)
                    .foregroundStyle(Theme.Common.subText)
            }
        }
        .foregroundStyle(Theme.Common.text)
    }

    @ViewBuilder
    private var envelope: some View {
        let width = Theme.Envelope.smallWidth
        let scale = width / Theme.Envelope.largeWidth
        if isOpened {
            ZStack(alignment: .top) {
                roll.camera.envelope.flap
                    .frame(height: Theme.Envelope.smallFlap)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6))
                Theme.Prints.underCard
                    .frame(height: 40)
                    .padding(.horizontal, 10)
                    .offset(y: 8)
                EnvelopeBody(camera: roll.camera, period: nil, scale: scale)
                    .frame(height: Theme.Envelope.smallHeight - Theme.Envelope.smallFlap)
                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 6, bottomTrailingRadius: 6))
                    .offset(y: Theme.Envelope.smallFlap)
            }
            .frame(width: width, height: Theme.Envelope.smallHeight, alignment: .top)
        } else {
            ClosedEnvelope(camera: roll.camera, period: nil, width: width)
                .frame(height: Theme.Envelope.smallHeight)
        }
    }
}
