import SwiftUI

extension CameraID {
    /// 封筒の色（spec §5）
    var envelope: EnvelopePalette {
        switch self {
        case .sunshine: EnvelopePalette(body: Color(hex: 0xF2B42A), flap: Color(hex: 0xE2A11A), band: Color(hex: 0x24315E))
        case .charcoal: EnvelopePalette(body: Color(hex: 0x3A3833), flap: Color(hex: 0x2E2C28), band: Color(hex: 0x1C1B19))
        case .pool: EnvelopePalette(body: Color(hex: 0x2E5FB4), flap: Color(hex: 0x28529C), band: Color(hex: 0x9CCBEA))
        case .green: EnvelopePalette(body: Color(hex: 0x3F8A45), flap: Color(hex: 0x357639), band: Color(hex: 0x161616))
        case .party: EnvelopePalette(body: Color(hex: 0x1E1E1E), flap: Color(hex: 0x151515), band: Color(hex: 0x2A2A2A))
        }
    }
}

struct EnvelopePalette {
    let body: Color
    let flap: Color
    let band: Color
}

/// 封筒の本体（紙のざらつき、ストライプ、帯、ラベル）。大きさは幅に合わせて変わる。
struct EnvelopeBody: View {
    let camera: CameraID
    /// 大きい封筒だけ撮影期間を出す
    let period: String?
    let scale: CGFloat

    var body: some View {
        let palette = camera.envelope
        ZStack(alignment: .bottomTrailing) {
            palette.body
            PaperTexture()
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(Array(camera.theme.stripes.enumerated()), id: \.offset) { _, color in
                    color.frame(height: Theme.Envelope.stripeHeight * scale)
                }
                palette.band.frame(height: Theme.Envelope.bandHeight * scale)
            }
            label
                .padding(.trailing, Theme.Envelope.labelTrailing * scale)
                .padding(.bottom, Theme.Envelope.labelBottom * scale)
        }
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Text(verbatim: camera.theme.name).font(camera.nameFont(size: max(14 * scale, 9)))
                Text(verbatim: period == nil ? "24EXP" : "・ 24EXP").font(Theme.dotFont(size: max(16 * scale, 10)))
            }
            if let period {
                Text(verbatim: period).font(Theme.dotFont(size: 16 * scale))
            }
        }
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 10 * max(scale, 0.6))
        .padding(.vertical, 6 * max(scale, 0.4))
        .foregroundStyle(Theme.Envelope.labelText)
        .background(Theme.Envelope.labelPaper)
    }
}

/// 紙の明暗と細かい筋
struct PaperTexture: View {
    var body: some View {
        ZStack {
            LinearGradient(stops: [.init(color: .white.opacity(0.14), location: 0),
                                   .init(color: .clear, location: 0.35),
                                   .init(color: .black.opacity(0.14), location: 1)],
                           startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                let reach = size.width + size.height
                var x = -reach
                var path = Path()
                while x < reach {
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: CGPoint(x: x + size.height * 1.4, y: 0))
                    x += 3
                }
                context.stroke(path, with: .color(.white.opacity(0.035)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

/// ふたが閉じた（または途中まで開いた）封筒
struct ClosedEnvelope: View {
    let camera: CameraID
    let period: String?
    let width: CGFloat
    /// 0＝閉じている、1＝開ききった
    var flapProgress: CGFloat = 0

    var body: some View {
        let scale = width / Theme.Envelope.largeWidth
        let radius = Theme.Envelope.cornerRadius * scale
        ZStack(alignment: .top) {
            // 中のプリント（ふたを開けると上にのぞく）
            Theme.Prints.paper
                .frame(height: Theme.Envelope.peekHeight * scale)
                .padding(.horizontal, Theme.Envelope.peekInset * scale)
                .offset(y: (Theme.Envelope.peekTop - flapProgress * Theme.Envelope.peekTravel) * scale)
            EnvelopeBody(camera: camera, period: period, scale: scale)
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .shadow(color: .black.opacity(0.55), radius: 12 * scale, y: 10 * scale)
            camera.envelope.flap
                .frame(height: Theme.Envelope.flapHeight * scale)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: radius, topTrailingRadius: radius))
                .overlay(alignment: .bottom) { Color.black.opacity(0.25).frame(height: 1) }
                .rotation3DEffect(.degrees(flapProgress * Theme.Envelope.flapMaxAngle),
                                  axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.4)
        }
        .frame(width: width, height: width * Theme.Envelope.largeHeight / Theme.Envelope.largeWidth)
    }
}
